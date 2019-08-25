extends Node

const VOWELS = ["А", "Е", "Ё", "И", "О", "У", "Ы", "Э", "Ю", "Я"]
const CONSONANTS =           ["Б", "В", "Г", "Д", "Ж", "З", "К", "Л", "М", "Н", "П", "Р", "С", "Т", "Ф", "Х", "Ц", "Ч", "Ш", "Щ"]
const CONSONANTS_EXCLUSIONS =[          "Г", "Д",           "К",           "Н",      "Р",      "Т",      "Х"]
const SPECIALS = ["Ь", "Ъ", "Й"]
const STOPS = [".", "!", "?", ";", ":"]

var conversation_active
var conversation_target
var conversation_sound_path
var in_choice
var max_choice = 0

func _ready():
	conversation_active = false
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
	if conversation_active:
		story_choose(player, max_choice - 1)
	conversation_active = false
	player.get_node("HUD/hud/Conversation").visible = false
	player.get_node("HUD/hud/Hints").visible = true

func start_conversation(player, target, conversation_name):
	conversation_active = true
	conversation_target = target
	player.get_node("HUD/hud/Hints").visible = false
	var conversation = player.get_node("HUD/hud/Conversation")
	conversation.visible = true
	max_choice = 0
	var story = conversation.get_node('StoryNode')
	var f = File.new()
	conversation_sound_path = ""
	var cp_player = "ink-scripts/%s/%s.ink.json" % [player.name_hint, conversation_name]
	var exists_cp_player = f.file_exists(cp_player)
	if exists_cp_player:
		conversation_sound_path = "sound/dialogues/%s/%s/" % [player.name_hint, conversation_name]
	var cp = "ink-scripts/%s.ink.json" % conversation_name
	var exists_cp = f.file_exists(cp)
	if exists_cp:
		conversation_sound_path = "sound/dialogues/root/%s/" % conversation_name
	story.LoadStory(cp_player if exists_cp_player else (cp if exists_cp else "ink-scripts/Monsieur.ink.json"))
	story.Reset()
	var conversation_actor_prev = conversation.get_node("VBox/VBoxText/HBoxTextPrev/ActorName")
	conversation_actor_prev.text = ""
	var conversation_text_prev = conversation.get_node("VBox/VBoxText/HBoxTextPrev/ConversationText")
	conversation_text_prev.text = ""
	story_proceed(player)

func story_choose(player, idx):
	var has_sound = false
	var conversation = player.get_node("HUD/hud/Conversation")
	var story = conversation.get_node('StoryNode')
	if story.CanChoose() and max_choice > 0 and idx < max_choice:
		var conversation_text = conversation.get_node("VBox/VBoxText/HBoxText/ConversationText")
		conversation_text.text = ""
		var conversation_actor = conversation.get_node("VBox/VBoxText/HBoxText/ActorName")
		conversation_actor.text = ""
		clear_choices(story, conversation)
		story.Choose(idx)
		if story.CanContinue():
			var conversation_text_prev = conversation.get_node("VBox/VBoxText/HBoxTextPrev/ConversationText")
			conversation_text_prev.text = story.Continue()
			var tags = story.GetCurrentTags()
			var conversation_actor_prev = conversation.get_node("VBox/VBoxText/HBoxTextPrev/ActorName")
			var actor_name = tags[0] if tags and tags.size() > 0 else player.name_hint
			conversation_actor_prev.text = actor_name + ": "
			if tags and tags.size() > 1:
				has_sound = play_sound_and_start_lipsync(tags[1], null) # no lipsync for choices
				in_choice = true
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
	$AudioStreamPlayer.stream = stream
	$AudioStreamPlayer.play()
	if phonetic:
		#print(phonetic)
		conversation_target.get_model().speak_text(phonetic, stream.get_length())
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
	var conversation = player.get_node("HUD/hud/Conversation")
	var story = conversation.get_node('StoryNode')
	var conversation_text = conversation.get_node("VBox/VBoxText/HBoxText/ConversationText")
	conversation_text.text = ""
	while story.CanContinue():
		conversation_text.text = conversation_text.text + " " + story.Continue()
	conversation_text.text = conversation_text.text.strip_edges()
	var conversation_actor = conversation.get_node("VBox/VBoxText/HBoxText/ActorName")
	var tags = story.GetCurrentTags()
	var actor_name = tags[0] if tags and tags.size() > 0 else (conversation_target.name_hint if conversation_target else null)
	conversation_actor.text = actor_name + ": " if actor_name and not conversation_text.text.empty() else ""
	if tags and tags.size() > 1:
		play_sound_and_start_lipsync(tags[1], tags[2] if tags.size() > 2 else text_to_phonetic(conversation_text.text))
	change_stretch_ratio(conversation)
	if story.CanChoose():
		display_choices(story, conversation)
	else:
		stop_conversation(player)

func clear_choices(story, conversation):
	var ch = story.GetChoices()
	var choices = conversation.get_node("VBox/VBoxChoices").get_children()
	var i = 1
	for c in choices:
		c.text = ""
		i += 1

func display_choices(story, conversation):
	var ch = story.GetChoices()
	var choices = conversation.get_node("VBox/VBoxChoices").get_children()
	var i = 1
	for c in choices:
		c.text = str(i) + ". " + ch[i - 1] if i <= ch.size() else ""
		i += 1
	max_choice = ch.size()

func _on_AudioStreamPlayer_finished():
	var player = get_node(game_params.player_path)
	var conversation = player.get_node("HUD/hud/Conversation")
	var story = conversation.get_node('StoryNode')
	if in_choice:
		story_proceed(player)
