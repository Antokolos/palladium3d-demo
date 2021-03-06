extends Node
class_name PLDConversationManager

const WIDTH_ADD = 2
const HEIGHT_ADD = 60
const MEETING_CONVERSATION_PREFIX = "Meeting_"
const MEETING_CONVERSATION_TEMPLATE = "%s%%s" % MEETING_CONVERSATION_PREFIX

signal meeting_started(player, target, initiator)
signal conversation_started(player, conversation_name, target, initiator)
signal meeting_finished(player, target, initiator)
signal conversation_finished(player, conversation_name, target, initiator, last_result)

onready var autoclose_timer = $AutocloseTimer
onready var pending_conversation_timer = $PendingConversationTimer

var conversation_name
var target
var initiator
var is_finalizing
var max_choice = 0
var current_actor_name = null
var previous_actor_name = null

var last_result : int = 0

var story_state_cache = {}
var pending_area_conversations = []

func _ready():
	conversation_name = null
	target = null
	initiator = null
	is_finalizing = false
	last_result = 0
	story_state_cache.clear()

func change_stretch_ratio(conversation):
	var conversation_text_prev = conversation.get_node("VBox/VBoxText/HBoxTextPrev/ConversationText")
	var conversation_text = conversation.get_node("VBox/VBoxText/HBoxText/ConversationText")
	var stretch_ratio = 10
	conversation_text_prev.set("size_flags_stretch_ratio", stretch_ratio)
	conversation_text.set("size_flags_stretch_ratio", stretch_ratio)

func discard_all_conversations(player):
	pending_area_conversations.clear()
	pending_conversation_timer.stop()
	stop_conversation(player)

func start_area_cutscene(conversation_name, cutscene_node = null, repeatable = false, exclusive = false, area_to_check : Area = null, pending_delay = 2.0):
	var player = game_state.get_player()
	if conversation_is_in_progress():
		if conversation_is_in_progress(conversation_name):
			return
		if exclusive:
			discard_all_conversations(player)
		else:
			for conversation in pending_area_conversations:
				if conversation_name == conversation.conversation_name:
					return
			pending_area_conversations.push_back(
				{
					"player" : player,
					"conversation_name" : conversation_name,
					"target" : null,
					"initiator" : null,
					"is_cutscene" : true,
					"cutscene_node" : cutscene_node,
					"repeatable" : repeatable,
					"area_to_check" : area_to_check,
					"pending_delay" : pending_delay
				}
			)
			return
	if repeatable or conversation_is_not_finished(conversation_name):
		player.rest()
		start_conversation(player, conversation_name, null, null, true, cutscene_node, repeatable)

func start_area_conversation_with_companion(conversations_map, repeatable = false, exclusive = false):
	for name_hint in conversations_map.keys():
		if game_state.is_in_party(name_hint):
			return start_area_conversation(conversations_map[name_hint], repeatable, exclusive)
	return false

func enable_conversation(conversation_name, enable):
	var cp_story = get_story_path(conversation_name)
	story_node.enable_conversation(cp_story, enable)

func start_area_conversation(conversation_name, repeatable = false, exclusive = false, area_to_check : Area = null, pending_delay = 2.0):
	var player = game_state.get_player()
	if conversation_is_in_progress():
		if conversation_is_in_progress(conversation_name):
			return false
		if exclusive:
			discard_all_conversations(player)
		else:
			for conversation in pending_area_conversations:
				if conversation_name == conversation.conversation_name:
					return false
			pending_area_conversations.push_back(
				{
					"player" : player,
					"conversation_name" : conversation_name,
					"target" : null,
					"initiator" : null,
					"is_cutscene" : false,
					"cutscene_node" : null,
					"repeatable" : repeatable,
					"area_to_check" : area_to_check,
					"pending_delay" : pending_delay
				}
			)
			return false
	if repeatable or conversation_is_not_finished(conversation_name):
		start_conversation(player, conversation_name, null, null, false, null, repeatable)
		return true
	return false

func start_pending_conversation_if_any():
	if pending_area_conversations.empty():
		return
	var c = pending_area_conversations.pop_front()
	if not c:
		return
	if conversation_is_finished(c.conversation_name) and not c.repeatable:
		return
	if c.pending_delay > 0.0:
		pending_conversation_timer.start(c.pending_delay)
		yield(pending_conversation_timer, "timeout")
	if conversation_is_in_progress():
		if conversation_is_in_progress(c.conversation_name):
			return
		for conversation in pending_area_conversations:
			if c.conversation_name == conversation.conversation_name:
				# This is highly unlikely, but let's check this anyway
				return
		pending_area_conversations.push_front(c)
		return
	start_conversation(
		c.player,
		c.conversation_name,
		c.target,
		c.initiator,
		c.is_cutscene,
		c.cutscene_node,
		c.repeatable,
		c.area_to_check
	)

func stop_conversation(player):
	if not conversation_is_in_progress():
		# Already stopped
		start_pending_conversation_if_any()
		return
	if not autoclose_timer.is_stopped():
		autoclose_timer.stop()
	story_node.increase_visit_count(last_result)
	var conversation_name_prev = conversation_name
	var target_prev = target
	var initiator_prev = initiator
	conversation_name = null
	target = null
	initiator = null
	current_actor_name = null
	previous_actor_name = null
	#is_finalizing = false -- this had some troubles with the lipsync_manager, it is better to not touch it now
	var hud = game_state.get_hud()
	if hud:
		hud.conversation.visible = false
		hud.show_game_ui(true)
	if conversation_name_prev.find(MEETING_CONVERSATION_PREFIX) == 0:
		emit_signal("meeting_finished", player, target_prev, initiator_prev)
	var cam = player.get_cam()
	if cam:
		cam.enable_use(true)
	emit_signal("conversation_finished", player, conversation_name_prev, target_prev, initiator_prev, last_result)
	start_pending_conversation_if_any()

func conversation_is_in_progress(conversation_name = null, target_name_hint = null):
	if not conversation_name:
		# Will return true if ANY conversation is in progress
		return self.conversation_name != null and self.conversation_name.length() > 0
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

func meeting_is_not_finished_exact(character1_name_hint, character2_name_hint):
	return not meeting_is_finished_exact(character1_name_hint, character2_name_hint)

func conversation_is_finished(conversation_name, target_name_hint = null):
	return not conversation_is_not_finished(conversation_name, target_name_hint)

func conversation_is_not_finished(conversation_name, target_name_hint = null):
	return check_story_not_finished(conversation_name, target_name_hint)

func conversation_result_was_achieved(conversation_name, result = 0, target_name_hint = null):
	return check_story_result_was_achieved(conversation_name, result, target_name_hint)

func get_story_path(conversation_name, target_name_hint = null):
	var cp = (("%s/" % target_name_hint) if target_name_hint else "") + "%s.ink.json" % conversation_name
	var cp_story
	if story_state_cache.has(cp):
		cp_story = story_state_cache.get(cp)
	else:
		var locale = TranslationServer.get_locale()
		var f = File.new()
		var fpath = "res://ink-scripts/%s/%s" % [locale, cp]
		var exists_cp = f.file_exists(fpath)
		if not exists_cp:
			push_warning("Story file %s not found" % fpath)
		cp_story = cp if exists_cp else "Default.ink.json"
		story_state_cache[cp] = cp_story
	return cp_story

func check_story_not_finished(conversation_name, target_name_hint = null):
	var cp_story = get_story_path(conversation_name, target_name_hint)
	return story_node.check_story_not_finished(cp_story)

func check_story_result_was_achieved(conversation_name, result = 0, target_name_hint = null):
	var cp_story = get_story_path(conversation_name, target_name_hint)
	return story_node.check_story_result_was_achieved(cp_story, result)

func init_story(conversation_name, target_name_hint = null, repeatable = false):
	var cp_story = get_story_path(conversation_name, target_name_hint)
	story_node.load_story(cp_story, false, repeatable)
	story_node.init_variables()
	return story_node

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

func start_conversation(player, conversation_name, target = null, initiator = null, is_cutscene = false, cutscene_node = null, repeatable = false, area_to_check : Area = null):
	if self.conversation_name == conversation_name:
		return
	if area_to_check and not area_to_check.overlaps_body(player):
		return
	var cp_story = get_story_path(conversation_name, target.get_name_hint() if target else null)
	if story_node.is_disabled(cp_story):
		return
	for actor in story_node.get_actors_name_hints(cp_story):
		var character = game_state.get_character(actor)
		if character:
			if character.is_stunned():
				# We can also emit signals and then restart the dialogue if we need to, but let's just remove the stun for now
				character.stun_stop()
			if not character.is_activated_flag():
				return
	if is_cutscene:
		cutscene_manager.start_cutscene(player, cutscene_node, conversation_name, target)
	else:
		player.get_cam().enable_use(false)
	emit_signal("conversation_started", player, conversation_name, target, initiator)
	self.target = target
	self.initiator = initiator
	self.is_finalizing = false
	self.last_result = 0
	self.conversation_name = conversation_name
	var hud = game_state.get_hud()
	hud.show_game_ui(false)
	var conversation = hud.conversation
	conversation.visible = true
	max_choice = 0
	var story = init_story(conversation_name, target.name_hint if target else null, repeatable)
	clear_actors_and_texts(player, conversation)
	story_proceed(player)

func clear_actors_and_texts(player, conversation):
	var conversation_text = conversation.get_node("VBox/VBoxText/HBoxText/ConversationText")
	var conversation_text_prev = conversation.get_node("VBox/VBoxText/HBoxTextPrev/ConversationText")
	conversation_text_prev.text = ""
	var conversation_actor = conversation.get_node("VBox/VBoxText/HBoxText/ActorName")
	var conversation_actor_prev = conversation.get_node("VBox/VBoxText/HBoxTextPrev/ActorName")
	conversation_actor_prev.text = ""
	var tags = story_node.get_current_tags_for_locale(TranslationServer.get_locale())
	var cur_text = story_node.current_text(TranslationServer.get_locale())
	if tags.has("finalizer") or cur_text.empty():
		conversation_text.text = ""
		conversation_actor.text = ""
	else:
		conversation_text.text = cur_text
		previous_actor_name = current_actor_name
		current_actor_name = tags["actor"] if tags and tags.has("actor") else player.name_hint
		conversation_actor.text = tr(current_actor_name) + ": "

func move_current_text_to_prev(conversation):
	var conversation_text = conversation.get_node("VBox/VBoxText/HBoxText/ConversationText")
	var conversation_text_prev = conversation.get_node("VBox/VBoxText/HBoxTextPrev/ConversationText")
	conversation_text_prev.text = conversation_text.text
	conversation_text.text = ""
	var conversation_actor = conversation.get_node("VBox/VBoxText/HBoxText/ActorName")
	var conversation_actor_prev = conversation.get_node("VBox/VBoxText/HBoxTextPrev/ActorName")
	conversation_actor_prev.text = conversation_actor.text
	conversation_actor.text = ""

func get_last_result() -> int:
	return last_result

func get_vvalue(dict):
	return dict["ru"] if settings.vlanguage == settings.VLANGUAGE_RU else (dict["en"] if settings.vlanguage == settings.VLANGUAGE_EN else null)

func story_choose(player, idx):
	var has_sound = false
	var conversation = game_state.get_hud().conversation
	var conversation_text = conversation.get_node("VBox/VBoxText/HBoxText/ConversationText")
	var conversation_actor = conversation.get_node("VBox/VBoxText/HBoxText/ActorName")
	lipsync_manager.stop_sound_and_lipsync(false)  # If the character has not finished speaking, but the player already decided to continue dialogue
	if is_finalizing or (not story_node.can_choose() and not story_node.can_continue() and idx == 0):
		stop_conversation(player)
	elif story_node.can_choose() and max_choice > 0 and idx < max_choice:
		move_current_text_to_prev(conversation)
		clear_choices(conversation)
		story_node.choose(idx)
		if story_node.can_continue():
			var texts = story_node.continue(true)
			conversation_text.text = texts[TranslationServer.get_locale()].strip_edges()
			var tags_dict = story_node.get_current_tags()
			var tags = tags_dict[TranslationServer.get_locale()]
			is_finalizing = tags and tags.has("finalizer")
			if is_finalizing:
				last_result = 0 if tags["finalizer"].empty() else tags["finalizer"].to_int()
				stop_conversation(player)
				return
			previous_actor_name = current_actor_name
			current_actor_name = tags["actor"] if tags and tags.has("actor") else player.name_hint
			conversation_actor.text = tr(current_actor_name) + ": " if current_actor_name else ""
			var vtags = get_vvalue(tags_dict)
			if vtags and vtags.has("voiceover"):
				# For simplicity, we are always using Russian text to autocreate lipsync
				# To get more correct representation of English phonemes, you can use 'transcription' tag in the Ink file
				# TODO: Alternatively, code for lipsync autocreation from English text should be written
				var text = "" if vtags.has("no_lipsync") else texts["ru"] #get_vvalue(texts)
				var transcription = vtags["transcription"] if vtags.has("transcription") and not vtags.has("no_lipsync") else null
				var character = game_state.get_character(current_actor_name)
				var pre_delay = float(tags["pre_delay"]) if tags and tags.has("pre_delay") else 0.0
				var post_delay = float(tags["post_delay"]) if tags and tags.has("post_delay") else 0.0
				has_sound = lipsync_manager.play_sound_and_start_lipsync(character, conversation_name, target.name_hint if target else null, vtags["voiceover"], text, transcription, pre_delay, post_delay)
			change_stretch_ratio(conversation)
		conversation.visible = settings.need_subtitles() or not has_sound
		if not has_sound:
			story_proceed(player)
	elif story_node.can_continue():
		story_proceed(player)

func proceed_story_immediately(player):
	if lipsync_manager.is_speaking():
		lipsync_manager.stop_sound_and_lipsync()
	else:
		story_proceed(player)

func story_proceed(player):
	var hud = game_state.get_hud()
	if not hud:
		return
	var conversation = hud.conversation
	var has_voiceover = false
	if story_node.can_continue():
		var conversation_text = conversation.get_node("VBox/VBoxText/HBoxText/ConversationText")
		move_current_text_to_prev(conversation)
		var texts = story_node.continue(false)
		conversation_text.text = texts[TranslationServer.get_locale()].strip_edges()
		var conversation_actor = conversation.get_node("VBox/VBoxText/HBoxText/ActorName")
		var tags_dict = story_node.get_current_tags()
		var tags = tags_dict[TranslationServer.get_locale()]
		is_finalizing = tags and tags.has("finalizer")
		if is_finalizing:
			last_result = 0 if tags["finalizer"].empty() else tags["finalizer"].to_int()
		previous_actor_name = current_actor_name
		current_actor_name = tags["actor"] if tags and tags.has("actor") else player.name_hint
		conversation_actor.text = tr(current_actor_name) + ": " if current_actor_name and not conversation_text.text.empty() else ""
		var vtags = get_vvalue(tags_dict)
		has_voiceover = vtags and vtags.has("voiceover")
		if has_voiceover:
			# For simplicity, we are always using Russian text to autocreate lipsync
			# To get more correct representation of English phonemes, you can use 'transcription' tag in the Ink file
			# TODO: Alternatively, code for lipsync autocreation from English text should be written
			var text = "" if vtags.has("no_lipsync") else texts["ru"] #get_vvalue(texts)
			var transcription = vtags["transcription"] if vtags.has("transcription") and not vtags.has("no_lipsync") else null
			var character = game_state.get_character(current_actor_name)
			var pre_delay = float(tags["pre_delay"]) if tags and tags.has("pre_delay") else 0.0
			var post_delay = float(tags["post_delay"]) if tags and tags.has("post_delay") else 0.0
			lipsync_manager.play_sound_and_start_lipsync(character, conversation_name, target.name_hint if target else null, vtags["voiceover"], text, transcription, pre_delay, post_delay)
		change_stretch_ratio(conversation)
	var can_continue = not is_finalizing and story_node.can_continue()
	var can_choose = not is_finalizing and story_node.can_choose()
	var choices = story_node.get_choices(TranslationServer.get_locale()) if can_choose else ([tr("CONVERSATION_CONTINUE")] if can_continue else [tr("CONVERSATION_END")])
	if not can_continue and not can_choose and not has_voiceover:
		if autoclose_timer.is_stopped():
			autoclose_timer.start()
		else:
			stop_conversation(player)
			return
	conversation.visible = settings.need_subtitles() or can_choose or not has_voiceover
	display_choices(conversation, choices, can_choose)

func is_finalizing():
	return is_finalizing

func clear_choices(conversation):
	var choices_text = conversation.get_node("VBox/HBoxChoices/VBoxChoices/ChoicesText")
	choices_text.bbcode_text = ""
	choices_text.visible = false

func display_choices(conversation, choices, can_choose):
	var choices_text = conversation.get_node("VBox/HBoxChoices/VBoxChoices/ChoicesText")
	var choices_font = choices_text.get_font("normal_font")
	max_choice = choices.size()
	choices_text.bbcode_text = ""
	choices_text.visible = (max_choice > 0)
	if max_choice == 0:
		return
	var max_width = 0
	var choices_height = 0
	choices_text.bbcode_text += "[table=1]"
	for i in range(0, max_choice):
		var cns = str(i + 1)
		var ic = common_utils.get_input_control("dialogue_option_%s" % cns, false) if can_choose else common_utils.get_input_control("dialogue_next", false)
		var ls = choices_font.get_string_size((cns if ic.empty() else ic) + ": " + choices[i])
		if ls.x > max_width:
			max_width = ls.x
		choices_height = choices_height + ls.y
		choices_text.bbcode_text += "[cell][color=red]" + (cns if ic.empty() else ic) + ":[/color] " + choices[i] + "[/cell]"
	choices_text.bbcode_text += "[/table]"
	max_width += WIDTH_ADD
	choices_height += HEIGHT_ADD
	choices_text.rect_min_size = Vector2(max_width, choices_height)

func get_current_actor():
	return game_state.get_character(current_actor_name) if current_actor_name else null

func get_previous_actor():
	return game_state.get_character(previous_actor_name) if previous_actor_name else null

func _on_AutocloseTimer_timeout():
	var player = game_state.get_player()
	stop_conversation(player)
