extends Node
class_name ConversationManager

const MEETING_CONVERSATION_PREFIX = "Meeting_"
const MEETING_CONVERSATION_TEMPLATE = "%s%%s" % MEETING_CONVERSATION_PREFIX

signal meeting_started(player, target, initiator)
signal conversation_started(player, conversation_name, target, initiator)
signal meeting_finished(player, target, initiator)
signal conversation_finished(player, conversation_name, target, initiator)

var conversation_name
var target
var initiator
var in_choice
var max_choice = 0

var story_state_cache = {}

func _ready():
	conversation_name = null
	target = null
	initiator = null
	in_choice = false
	story_state_cache.clear()

func change_stretch_ratio(conversation):
	var conversation_text_prev = conversation.get_node("VBox/VBoxText/HBoxTextPrev/ConversationText")
	var conversation_text = conversation.get_node("VBox/VBoxText/HBoxText/ConversationText")
	var stretch_ratio = 10
	conversation_text_prev.set("size_flags_stretch_ratio", stretch_ratio)
	conversation_text.set("size_flags_stretch_ratio", stretch_ratio)

func start_area_cutscene(conversation_name, cutscene_node = null):
	var player = game_params.get_player()
	if not conversation_manager.conversation_is_in_progress() and conversation_manager.conversation_is_not_finished(conversation_name):
		player.rest()
		conversation_manager.start_conversation(player, conversation_name, null, null, true, cutscene_node)

func start_area_conversation(conversation_name):
	var player = game_params.get_player()
	if not conversation_manager.conversation_is_in_progress() and conversation_manager.conversation_is_not_finished(conversation_name):
		conversation_manager.start_conversation(player, conversation_name)

func stop_conversation(player):
	for companion in game_params.get_companions():
		companion.set_speak_mode(false)
	var conversation_name_prev = conversation_name
	var target_prev = target
	var initiator_prev = initiator
	conversation_name = null
	target = null
	initiator = null
	var hud = game_params.get_hud()
	hud.conversation.visible = false
	hud.quick_items_panel.visible = true
	if conversation_name_prev.find(MEETING_CONVERSATION_PREFIX) == 0:
		emit_signal("meeting_finished", player, target_prev, initiator_prev)
	player.get_cam().enable_use(true)
	emit_signal("conversation_finished", player, conversation_name_prev, target_prev, initiator_prev)

func conversation_is_in_progress(conversation_name = null, target_name_hint = null):
	if not conversation_name:
		# Will return true if ANY conversation is in progress
		return self.conversation_name != null
	if not target_name_hint or not target:
		return self.conversation_name == conversation_name
	return self.conversation_name == conversation_name and self.target.name_hint == target_name_hint

func meeting_is_in_progress(character1_name_hint, character2_name_hint):
	var conversation_name_1 = MEETING_CONVERSATION_TEMPLATE % character1_name_hint
	var conversation_name_2 = MEETING_CONVERSATION_TEMPLATE % character2_name_hint
	return conversation_is_in_progress(conversation_name_1, character2_name_hint) or conversation_is_in_progress(conversation_name_2, character1_name_hint)


func meeting_is_finished_exact(initiator_name_hint, target_name_hint):
	return conversation_is_finished(MEETING_CONVERSATION_TEMPLATE % initiator_name_hint, target_name_hint)

func meeting_is_finished(character1_name_hint, character2_name_hint):
	var conversation_name_1 = MEETING_CONVERSATION_TEMPLATE % character1_name_hint
	var conversation_name_2 = MEETING_CONVERSATION_TEMPLATE % character2_name_hint
	return conversation_is_finished(conversation_name_1, character2_name_hint) or conversation_is_finished(conversation_name_2, character1_name_hint)

func meeting_is_not_finished(character1_name_hint, character2_name_hint):
	return not meeting_is_finished(character1_name_hint, character2_name_hint)

func conversation_is_finished(conversation_name, target_name_hint = null):
	return not conversation_is_not_finished(conversation_name, target_name_hint)

func conversation_is_not_finished(conversation_name, target_name_hint = null):
	return check_story_not_finished(conversation_name, target_name_hint)

func check_story_not_finished(conversation_name, target_name_hint = null):
	var story = StoryNode
	var cp = ("%s/" % target_name_hint if target_name_hint else "") + "%s.ink.json" % conversation_name
	var cp_story
	if story_state_cache.has(cp):
		cp_story = story_state_cache.get(cp)
	else:
		var locale = TranslationServer.get_locale()
		var f = File.new()
		var exists_cp = f.file_exists("res://ink-scripts/%s/%s" % [locale, cp])
		cp_story = cp if exists_cp else "Default.ink.json"
		story_state_cache[cp] = cp_story
	return story.CheckStoryNotFinished("res://ink-scripts", cp_story)

func init_story(conversation_name, target_name_hint = null):
	var locale = TranslationServer.get_locale()
	var story = StoryNode
	var f = File.new()
	var cp = ("%s/" % target_name_hint if target_name_hint else "") + "%s.ink.json" % conversation_name
	var exists_cp = f.file_exists("res://ink-scripts/%s/%s" % [locale, cp])
	story.LoadStory("res://ink-scripts", cp if exists_cp else "Default.ink.json", false)
	story.InitVariables(game_params, game_params.story_vars, game_params.party)
	return story

func conversation_active():
	return conversation_name and conversation_name.length() > 0

func arrange_meeting(player, target, initiator, is_cutscene = false, cutscene_node = null):
	if meeting_is_in_progress(target.name_hint, initiator.name_hint):
		return false
	if meeting_is_not_finished(target.name_hint, initiator.name_hint):
		if not initiator.is_in_party():
			initiator.join_party()
		if not target.is_in_party():
			target.join_party()
		var conversation_name = MEETING_CONVERSATION_TEMPLATE % initiator.name_hint
		emit_signal("meeting_started", player, target, initiator)
		start_conversation(player, conversation_name, target, initiator, is_cutscene, cutscene_node)
		return true
	return false

func start_conversation(player, conversation_name, target = null, initiator = null, is_cutscene = false, cutscene_node = null):
	if self.conversation_name == conversation_name:
		return
	if is_cutscene:
		cutscene_manager.start_cutscene(player, cutscene_node, conversation_name, target)
	else:
		player.get_cam().enable_use(false)
	emit_signal("conversation_started", player, conversation_name, target, initiator)
	self.target = target
	self.initiator = initiator
	self.conversation_name = conversation_name
	var hud = game_params.get_hud()
	hud.quick_items_panel.visible = false
	hud.inventory.visible = false
	var conversation = hud.conversation
	conversation.visible = true
	max_choice = 0
	var story = init_story(conversation_name, target.name_hint if target else null)
	clear_actors_and_texts(player, story, conversation)
	story_proceed(player)

func clear_actors_and_texts(player, story, conversation):
	var conversation_text = conversation.get_node("VBox/VBoxText/HBoxText/ConversationText")
	var conversation_text_prev = conversation.get_node("VBox/VBoxText/HBoxTextPrev/ConversationText")
	conversation_text_prev.text = ""
	var conversation_actor = conversation.get_node("VBox/VBoxText/HBoxText/ActorName")
	var conversation_actor_prev = conversation.get_node("VBox/VBoxText/HBoxTextPrev/ActorName")
	conversation_actor_prev.text = ""
	var tags = story.GetCurrentTags(TranslationServer.get_locale())
	var cur_text = story.CurrentText(TranslationServer.get_locale())
	if tags.has("finalizer") or cur_text.empty():
		conversation_text.text = ""
		conversation_actor.text = ""
	else:
		conversation_text.text = cur_text
		var actor_name = tags["actor"] if tags and tags.has("actor") else player.name_hint
		conversation_actor.text = tr(actor_name) + ": "

func move_current_text_to_prev(conversation):
	var conversation_text = conversation.get_node("VBox/VBoxText/HBoxText/ConversationText")
	var conversation_text_prev = conversation.get_node("VBox/VBoxText/HBoxTextPrev/ConversationText")
	conversation_text_prev.text = conversation_text.text
	conversation_text.text = ""
	var conversation_actor = conversation.get_node("VBox/VBoxText/HBoxText/ActorName")
	var conversation_actor_prev = conversation.get_node("VBox/VBoxText/HBoxTextPrev/ActorName")
	conversation_actor_prev.text = conversation_actor.text
	conversation_actor.text = ""

func get_vvalue(dict):
	return dict["ru"] if settings.vlanguage == settings.VLANGUAGE_RU else (dict["en"] if settings.vlanguage == settings.VLANGUAGE_EN else null)

func story_choose(player, idx):
	var has_sound = false
	var conversation = game_params.get_hud().conversation
	var conversation_text = conversation.get_node("VBox/VBoxText/HBoxText/ConversationText")
	var conversation_actor = conversation.get_node("VBox/VBoxText/HBoxText/ActorName")
	var story = StoryNode
	if not story.CanChoose() and not story.CanContinue() and idx == 0:
		stop_conversation(player)
	elif story.CanChoose() and max_choice > 0 and idx < max_choice:
		move_current_text_to_prev(conversation)
		clear_choices(story, conversation)
		story.Choose(idx)
		if story.CanContinue():
			var texts = story.Continue(true)
			conversation_text.text = texts[TranslationServer.get_locale()].strip_edges()
			var tags_dict = story.GetCurrentTags()
			var tags = tags_dict[TranslationServer.get_locale()]
			var finalizer = tags and tags.has("finalizer")
			if finalizer:
				stop_conversation(player)
				return
			var actor_name = tags["actor"] if not finalizer and tags and tags.has("actor") else player.name_hint
			conversation_actor.text = tr(actor_name) + ": " if actor_name else ""
			var vtags = get_vvalue(tags_dict)
			if vtags and vtags.has("voiceover"):
				var character = game_params.get_character(actor_name)
				character.set_speak_mode(true)
				has_sound = lipsync_manager.play_sound_and_start_lipsync(character, conversation_name, target.name_hint if target else null, vtags["voiceover"]) # no lipsync for choices
				in_choice = true
			change_stretch_ratio(conversation)
		if not has_sound:
			story_proceed(player)
	elif story.CanContinue():
		story_proceed(player)

func proceed_story_immediately(player):
	if $AudioStreamPlayer.is_playing():
		$AudioStreamPlayer.stop()
		story_proceed(player)

func story_proceed(player):
	in_choice = false
	var conversation = game_params.get_hud().conversation
	var story = StoryNode
	if story.CanContinue():
		var conversation_text = conversation.get_node("VBox/VBoxText/HBoxText/ConversationText")
		move_current_text_to_prev(conversation)
		var texts = story.Continue(false)
		conversation_text.text = texts[TranslationServer.get_locale()].strip_edges()
		var conversation_actor = conversation.get_node("VBox/VBoxText/HBoxText/ActorName")
		var tags_dict = story.GetCurrentTags()
		var tags = tags_dict[TranslationServer.get_locale()]
		var actor_name = tags["actor"] if tags and tags.has("actor") else player.name_hint
		conversation_actor.text = tr(actor_name) + ": " if actor_name and not conversation_text.text.empty() else ""
		var vtags = get_vvalue(tags_dict)
		if vtags and vtags.has("voiceover"):
			var text = get_vvalue(texts)
			var character = game_params.get_companion(actor_name)
			character.set_speak_mode(true)
			lipsync_manager.play_sound_and_start_lipsync(character, conversation_name, target.name_hint if target else null, vtags["voiceover"], text, vtags["transcription"] if vtags.has("transcription") else null)
		change_stretch_ratio(conversation)
	var choices = story.GetChoices(TranslationServer.get_locale()) if story.CanChoose() else ([tr("CONVERSATION_CONTINUE")] if story.CanContinue() else [tr("CONVERSATION_END")])
	display_choices(story, conversation, choices)

func clear_choices(story, conversation):
	var ch = story.GetChoices(TranslationServer.get_locale())
	var choices = conversation.get_node("VBox/VBoxChoices").get_children()
	var i = 1
	for c in choices:
		c.text = ""
		i += 1

func display_choices(story, conversation, choices):
	var choice_nodes = conversation.get_node("VBox/VBoxChoices").get_children()
	var i = 1
	for c in choice_nodes:
		c.text = str(i) + ". " + choices[i - 1] if i <= choices.size() else ""
		i += 1
	max_choice = choices.size()