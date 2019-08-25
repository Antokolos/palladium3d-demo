extends Node

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

func sanitize_text(text):
	return text.replace("_", "")

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
			conversation_text_prev.text = sanitize_text(story.Continue())
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
		print(phonetic)
		conversation_target.get_model().speak_text(phonetic, stream.get_length())
	return true

func letter_vowel(letter):
	var vowels = ["А", "Е", "Ё", "И", "О", "У", "Ы", "Э", "Ю", "Я"]
	return vowels.has(letter.to_upper())

func letter_consonant(letter):
	var consonants = ["Б", "В", "Г", "Д", "Ж", "З", "Й", "К", "Л", "М", "Н", "П", "Р", "С", "Т", "Ф", "Х", "Ц", "Ч", "Ш", "Щ"]
	return consonants.has(letter.to_upper())

func letter_consonant_important(letter):
	var consonants = ["В", "З", "Л", "М", "Ш", "Ц", "Ж"]
	return consonants.has(letter.to_upper())

func letter_consonant_special(letter):
	var special_consonants = ["Ж", "Ш", "Ц"]
	return special_consonants.has(letter.to_upper())

func letter_special(letter):
	var specials = ["Ь", "Ъ"]
	return specials.has(letter.to_upper())

func letter_skip(letter):
	return not (letter_vowel(letter) or letter_consonant(letter))

func letter_to_phonetic(letter, prev_letter, is_word_begin):
	var l = letter.to_upper()
	if letter_special(l) or letter_skip(l):
		return ""
	var pl = prev_letter.to_upper()
	var pl_vowel = letter_vowel(pl)
	var pl_consonant = letter_consonant(pl)
	var pl_consonant_special = letter_consonant_special(pl)
	var pl_special = letter_special(pl)
	match l:
		"Е":
			return "ЙЭ" if pl_vowel or is_word_begin or pl_special else "Э"
		"Ё":
			return "ЙО" if pl_vowel or is_word_begin or pl_special else "О"
		"Ю":
			return "ЙУ" if pl_vowel or is_word_begin or pl_special else "У"
		"Я":
			return "ЙА" if pl_vowel or is_word_begin or pl_special else "А"
		"И":
			return "Ы" if pl_consonant_special else "И"
		_:
			#return letter if not letter_consonant(letter) or letter_consonant_important(letter) else ""
			return letter

func text_to_phonetic(text):
	var result = ""
	var words = text.split(" ", false)
	for word in words:
		var i = 0
		var wl = word.length()
		var prev_letter = ""
		var dont_speak = false
		var vowels = {}
		var consonants = {}
		var addition = ""
		while i < wl:
			var letter = word[i]
			var word_begin = (i == 0)
			consonants[i] = ""
			vowels[i] = ""
			if letter == "_":
				dont_speak = true
				i = i + 1
				continue
			if dont_speak:
				addition = addition + "."
			if letter_consonant(letter):
				consonants[i] = letter_to_phonetic(letter, prev_letter, word_begin)
			elif letter_vowel(letter) and not dont_speak:
				vowels[i] = letter_to_phonetic(letter, prev_letter, word_begin)
			if not letter_skip(letter):
				prev_letter = letter
			i = i + 1
		var phonetic = {}
		var pi = 2
		i = wl - 1
		phonetic[0] = ""
		phonetic[1] = ""
		phonetic[2] = ""
		#print(vowels)
		#print(consonants)
		while i >= 0:
			if (pi == 2 or pi == 0) and consonants[i] != "":
				phonetic[pi] = consonants[i]
				if pi == 0:
					break
			if pi == 2 and vowels[i] != "":
				phonetic[1] = vowels[i]
				pi = 0
			i = i - 1
		result = result + phonetic[0] + phonetic[1] + phonetic[2] + addition + " "
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
	conversation_text.text = sanitize_text(conversation_text.text)
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
