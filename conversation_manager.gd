extends Node

const VOWELS = ["А", "Е", "Ё", "И", "О", "У", "Ы", "Э", "Ю", "Я"]
const CONSONANTS =           ["Б", "В", "Г", "Д", "Ж", "З", "К", "Л", "М", "Н", "П", "Р", "С", "Т", "Ф", "Х", "Ц", "Ч", "Ш", "Щ"]
const CONSONANTS_EXCLUSIONS =[          "Г", "Д",           "К",           "Н",      "Р",      "Т",      "Х"]
const SPECIALS = ["Ь", "Ъ", "Й"]
const STOPS = [".", "!", "?", ";", ":"]
const MINIMUM_AUTO_ADVANCE_TIME_SEC = 2.1

var conversation_name
var conversation_target
var conversation_sound_path
var in_choice
var max_choice = 0

func _ready():
	conversation_name = null
	conversation_target = null
	conversation_sound_path = ""
	in_choice = false

func change_stretch_ratio(conversation):
	var conversation_text_prev = conversation.get_node("VBox/VBoxText/HBoxTextPrev/ConversationText")
	var conversation_text = conversation.get_node("VBox/VBoxText/HBoxText/ConversationText")
	var stretch_ratio = 7
	conversation_text_prev.set("size_flags_stretch_ratio", stretch_ratio)
	conversation_text.set("size_flags_stretch_ratio", stretch_ratio)

func stop_conversation(player):
	conversation_name = null
	var hud = player.get_hud()
	hud.get_node("Conversation").visible = false
	hud.get_node("Hints").visible = true

func conversation_is_finished(player, target, conversation_name):
	return not conversation_is_not_finished(player, target, conversation_name)

func conversation_is_not_finished(player, target, conversation_name):
	var conversation = player.get_hud().get_node("Conversation")
	var story = init_story(player, conversation, conversation_name)
	return story.CanContinue() or story.CanChoose()

func init_story(player, conversation, conversation_name):
	var locale = TranslationServer.get_locale()
	var story = conversation.get_node('StoryNode')
	var f = File.new()
	conversation_sound_path = ""
	var cp_player = "%s/%s.ink.json" % [player.name_hint, conversation_name]
	var exists_cp_player = f.file_exists("ink-scripts/%s/%s" % [locale, cp_player])
	if exists_cp_player:
		conversation_sound_path = "sound/dialogues/%s/%s/%s/" % [locale, player.name_hint, conversation_name]
	var cp = "%s.ink.json" % conversation_name
	var exists_cp = f.file_exists("ink-scripts/%s/%s" % [locale, cp])
	if exists_cp:
		conversation_sound_path = "sound/dialogues/%s/root/%s/" % [locale, conversation_name]
	story.LoadStory("ink-scripts", cp_player if exists_cp_player else (cp if exists_cp else "Monsieur.ink.json"))
	return story

func conversation_active():
	return conversation_name and conversation_name.length() > 0
 
func start_conversation(player, target, conversation_name):
	if self.conversation_name == conversation_name:
		return
	self.conversation_name = conversation_name
	conversation_target = target
	player.get_hud().get_node("Hints").visible = false
	var conversation = player.get_hud().get_node("Conversation")
	conversation.visible = true
	max_choice = 0
	var story = init_story(player, conversation, conversation_name)
	clear_actors_and_texts(player, story, conversation)
	story_proceed(player)

func clear_actors_and_texts(player, story, conversation):
	var conversation_text = conversation.get_node("VBox/VBoxText/HBoxText/ConversationText")
	var conversation_text_prev = conversation.get_node("VBox/VBoxText/HBoxTextPrev/ConversationText")
	conversation_text_prev.text = ""
	conversation_text.text = story.CurrentText(TranslationServer.get_locale())
	var conversation_actor = conversation.get_node("VBox/VBoxText/HBoxText/ActorName")
	var conversation_actor_prev = conversation.get_node("VBox/VBoxText/HBoxTextPrev/ActorName")
	conversation_actor_prev.text = ""
	var tags = story.GetCurrentTags(TranslationServer.get_locale())
	var actor_name = tags[0] if tags and tags.size() > 0 else player.name_hint
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

func story_choose(player, idx):
	var has_sound = false
	var conversation = player.get_hud().get_node("Conversation")
	var conversation_text = conversation.get_node("VBox/VBoxText/HBoxText/ConversationText")
	var conversation_actor = conversation.get_node("VBox/VBoxText/HBoxText/ActorName")
	var story = conversation.get_node('StoryNode')
	if not story.CanChoose() and not story.CanContinue() and idx == 0:
		stop_conversation(player)
	elif story.CanChoose() and max_choice > 0 and idx < max_choice:
		move_current_text_to_prev(conversation)
		clear_choices(story, conversation)
		story.Choose(idx)
		if story.CanContinue():
			conversation_text.text = story.Continue(TranslationServer.get_locale()).strip_edges()
			var tags = story.GetCurrentTags(TranslationServer.get_locale())
			var finalizer = tags and tags.size() > 0 and tags[0] == "finalizer"
			if finalizer:
				stop_conversation(player)
				return
			var actor_name = tags[0] if not finalizer and tags and tags.size() > 0 else player.name_hint
			conversation_actor.text = tr(actor_name) + ": "
			if tags and tags.size() > 1:
				has_sound = play_sound_and_start_lipsync(tags[1], null) # no lipsync for choices
				in_choice = true
			change_stretch_ratio(conversation)
		if not has_sound:
			story_proceed(player)

func proceed_story_immediately(player):
	if $AudioStreamPlayer.is_playing():
		$AudioStreamPlayer.stop()
		story_proceed(player)

func play_sound_and_start_lipsync(file_name, phonetic):
	var ogg_file = File.new()
	ogg_file.open(conversation_sound_path + file_name, File.READ)
	var bytes = ogg_file.get_buffer(ogg_file.get_len())
	var stream = AudioStreamOGGVorbis.new()
	stream.data = bytes
	var length = stream.get_length()
	$ShortPhraseTimer.wait_time = 0.01 if length >= MINIMUM_AUTO_ADVANCE_TIME_SEC else MINIMUM_AUTO_ADVANCE_TIME_SEC - length
	$AudioStreamPlayer.stream = stream
	$AudioStreamPlayer.play()
	if phonetic:
		#print(phonetic)
		conversation_target.get_model().speak_text(phonetic, length)
	return true

func letter_vowel(letter):
	return VOWELS.has(letter.to_upper())

func letter_consonant(letter):
	return CONSONANTS.has(letter.to_upper())

func letter_stop(letter):
	return STOPS.has(letter)

func letter_skip(letter, use_exclusions):
	var l = letter.to_upper()
	return SPECIALS.has(l) or (use_exclusions and CONSONANTS_EXCLUSIONS.has(l)) or not (VOWELS.has(l) or CONSONANTS.has(l))

func letter_to_phonetic(letter, use_exclusions):
	var l = letter.to_upper()
	if letter_stop(l):
		return "..."
	if letter_skip(l, use_exclusions):
		return ""
	match l:
		"Е":
			return "Э"
		"Ё":
			return "О"
		"Ю":
			return "У"
		"Я":
			return "А"
		_:
			return letter

func text_to_phonetic(text):
	var result = ""
	var words = text.split(" ", false)
	for word in words:
		var i = 0
		var wl = word.length()
		var use_exclusions = false
		while i < wl:
			var letter = word[i]
			result = result + letter_to_phonetic(letter, use_exclusions)
			use_exclusions = true
			i = i + 1
		result = result + " "
	return result

func story_proceed(player):
	in_choice = false
	var conversation = player.get_hud().get_node("Conversation")
	var story = conversation.get_node('StoryNode')
	if story.CanContinue():
		var conversation_text = conversation.get_node("VBox/VBoxText/HBoxText/ConversationText")
		move_current_text_to_prev(conversation)
		while story.CanContinue():
			conversation_text.text = conversation_text.text + " " + story.Continue(TranslationServer.get_locale())
		conversation_text.text = conversation_text.text.strip_edges()
		var conversation_actor = conversation.get_node("VBox/VBoxText/HBoxText/ActorName")
		var tags = story.GetCurrentTags(TranslationServer.get_locale())
		var actor_name = tags[0] if tags and tags.size() > 0 else (conversation_target.name_hint if conversation_target else null)
		conversation_actor.text = tr(actor_name) + ": " if actor_name and not conversation_text.text.empty() else ""
		if tags and tags.size() > 1:
			play_sound_and_start_lipsync(tags[1], tags[2] if tags.size() > 2 else text_to_phonetic(conversation_text.text))
		change_stretch_ratio(conversation)
	display_choices(story, conversation, story.GetChoices(TranslationServer.get_locale()) if story.CanChoose() else [tr("end_conversation")])

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

func _on_AudioStreamPlayer_finished():
	var player = get_node(game_params.player_path)
	var conversation = player.get_hud().get_node("Conversation")
	var story = conversation.get_node('StoryNode')
	if in_choice:
		story_proceed(player)
	elif story.CanChoose():
		var ch = story.GetChoices(TranslationServer.get_locale())
		if ch.size() == 1:
			$ShortPhraseTimer.start()

func _on_ShortPhraseTimer_timeout():
	var player = get_node(game_params.player_path)
	story_choose(player, 0)
