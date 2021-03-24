extends Node
class_name PLDLipsyncManager

const VOWELS = ["А", "Е", "Ё", "И", "О", "У", "Ы", "Э", "Ю", "Я"]
const CONSONANTS =           ["Б", "В", "Г", "Д", "Ж", "З", "К", "Л", "М", "Н", "П", "Р", "С", "Т", "Ф", "Х", "Ц", "Ч", "Ш", "Щ"]
const CONSONANTS_EXCLUSIONS =[          "Г", "Д",           "К",           "Н",      "Р",      "Т",      "Х"]
const SPECIALS = ["Ь", "Ъ", "Й"]
const STOPS = [".", "!", "?", ";", ":"]
const MINIMUM_AUTO_ADVANCE_TIME_SEC = 1.8
const PHRASE_PAUSE_TIMER_SCALE_COEF = 0.7
const PHRASE_PAUSE_TIMER_MIN_S = 0.02

onready var audio_stream_player = $AudioStreamPlayer
onready var short_phrase_timer = $ShortPhraseTimer
onready var phrase_pause_timer = $PhrasePauseTimer

var current_speaker = null
var current_phonetic = null

func _ready():
	conversation_manager.connect("conversation_finished", self, "_on_conversation_finished")

func _on_conversation_finished(player, conversation_name, target, initiator, last_result):
	stop_sound_and_lipsync(false)

func is_speaking():
	return audio_stream_player.is_playing() \
		or not short_phrase_timer.is_stopped() \
		or not phrase_pause_timer.is_stopped()

func stop_sound_and_lipsync(and_continue_conversation = true):
	for character_speaker in game_state.get_characters():
		character_speaker.get_model().stop_speaking()
	current_speaker = null
	current_phonetic = null
	var was_speaking = false
	if audio_stream_player.is_playing():
		audio_stream_player.stop()
		was_speaking = true
	audio_stream_player.stream = null
	if not short_phrase_timer.is_stopped():
		short_phrase_timer.stop()
		was_speaking = true
	if not phrase_pause_timer.is_stopped():
		phrase_pause_timer.stop()
		was_speaking = true
	if was_speaking and and_continue_conversation:
		continue_conversation()

func get_conversation_sound_path(conversation_name, target_name_hint = null):
	var locale = "ru" if settings.vlanguage == settings.VLANGUAGE_RU else ("en" if settings.vlanguage == settings.VLANGUAGE_EN else null)
	if not locale:
		return null
	return "res://sound/dialogues/%s/%s/%s/" % [locale, target_name_hint if target_name_hint else "root", conversation_name]

func play_sound_and_start_lipsync(character, conversation_name, target_name_hint, file_name, text = null, transcription = null):
	var conversation_sound_path = get_conversation_sound_path(conversation_name, target_name_hint)
	if not conversation_sound_path:
		return false
	var stream = load(conversation_sound_path + file_name)
	if not stream:
		return false
	if stream is AudioStreamOGGVorbis:
		stream.set_loop(false)
	elif stream is AudioStreamSample:
		stream.set_loop_mode(AudioStreamSample.LoopMode.LOOP_DISABLED)
	else:
		return false
	var length = stream.get_length()
	short_phrase_timer.wait_time = 0.01 if length >= MINIMUM_AUTO_ADVANCE_TIME_SEC else MINIMUM_AUTO_ADVANCE_TIME_SEC - length
	audio_stream_player.stream = stream
	current_speaker = character
	current_phonetic = transcription if transcription else (text_to_phonetic(text.strip_edges()) if text else null)
	phrase_pause_timer.start(randf() * PHRASE_PAUSE_TIMER_SCALE_COEF + PHRASE_PAUSE_TIMER_MIN_S)
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

func _on_AudioStreamPlayer_finished():
	if not audio_stream_player.stream:
		return
	var length = audio_stream_player.stream.get_length()
	if audio_stream_player.get_playback_position() >= length:
		short_phrase_timer.start()

func _on_ShortPhraseTimer_timeout():
	continue_conversation()

func continue_conversation():
	current_speaker = null
	current_phonetic = null
	var player = game_state.get_player()
	if conversation_manager.is_finalizing():
		conversation_manager.stop_conversation(player)
	elif story_node.can_continue():
		conversation_manager.story_proceed(player)
	elif story_node.can_choose():
		var ch = story_node.get_choices(TranslationServer.get_locale())
		if ch.size() == 1:
			conversation_manager.story_choose(player, 0)
	else:
		conversation_manager.stop_conversation(player)

func _on_PhrasePauseTimer_timeout():
	if not audio_stream_player.stream:
		return
	audio_stream_player.play()
	if not current_speaker or not current_phonetic:
		return
	current_speaker.get_model().speak_text(current_phonetic, audio_stream_player.stream.get_length())