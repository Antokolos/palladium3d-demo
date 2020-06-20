extends PLDCharacterModel
class_name PLDPlayerModel

const PHRASE_WITH_ANIM_LEN_THRESHOLD = 10

export var backpack_animation_player_path = ""
export var backpack_speak_animations = {}
export var backpack_rest_animations = {}
export var backpack_cutscene_animations = {}

export var speak_shots_max = 2

onready var backpack_animation_player = get_node(backpack_animation_player_path) if not backpack_animation_player_path.empty() else null
onready var speech_timer = get_node("SpeechTimer")

var speech_states = []
var speech_idx = 0

func toggle_head(enable):
	var sk = get_node(main_skeleton)
	for m in sk.get_children():
		if m is MeshInstance:
			if m.get_layer_mask_bit(1):
				m.set_layer_mask_bit(0, enable)

func set_simple_mode(sm):
	.set_simple_mode(sm)
	toggle_head(not sm)

func do_rest_shot(shot_idx):
	.do_rest_shot(shot_idx)
	if can_do_rest_shot():
		if backpack_animation_player and backpack_rest_animations.has(shot_idx):
			backpack_animation_player.play(backpack_rest_animations[shot_idx])

func is_speak_active():
	return $AnimationTree.get("parameters/SpeakShot/active")

func do_speak_shot(shot_idx):
	$AnimationTree.set("parameters/SpeakTransition/current", shot_idx)
	$AnimationTree.set("parameters/SpeakShot/active", true)
	if backpack_animation_player and backpack_speak_animations.has(shot_idx):
		backpack_animation_player.play(backpack_speak_animations[shot_idx])

func stop_speak_shot():
	$AnimationTree.set("parameters/SpeakShot/active", false)

func play_cutscene(cutscene_id):
	.play_cutscene(cutscene_id)
	if backpack_animation_player and backpack_cutscene_animations.has(cutscene_id):
		backpack_animation_player.play(backpack_cutscene_animations[cutscene_id])

func set_transition_lips(t):
	var transition = $AnimationTree.get("parameters/Transition_Lips/current")
	if transition != t:
		$AnimationTree.set("parameters/Transition_Lips/current", t)

func get_lips_transition_by_phoneme(phoneme):
	var p = phoneme.to_upper()
	match p:
		"IY", "IE", "И", "Ы":
			return 1
		"IH", "EY", "EH", "AE", "AH", "AY", "AW", "E", "EE", "AN", "H", "Х":
			return 2
		"AA", "AO", "AR", "А":
			return 3
		"OW", "UW", "UE", "OY", "W", "О":
			return 4
		"UH", "ER", "У":
			return 5
		"Y", "Й":
			return 6
		"L", "T", "D", "Л", "Т", "Д", "Р":
			return 7
		"R":
			return 8
		"M", "P", "B", "М", "П", "Б":
			return 9
		"N", "Н":
			return 10
		"F", "V", "Ф", "В":
			return 11
		"TH", "DH":
			return 12
		"S", "Z", "С", "З", "Ц":
			return 13
		"SH", "ZH", "CH", "Ж", "Ш", "Щ", "Ч":
			return 14
		"G", "K", "Г", "К":
			return 15
		"J":
			return 16
		"Э":
			return 17
		".":
			return 0
		_:
			return -1

func walk(look_angle_deg, is_crouching = false, is_sprinting = false):
	.walk(look_angle_deg, is_crouching, is_sprinting)
	stop_speak_shot()

func can_do_speak_shot():
	return speak_shots_max > 0 and speech_states.size() > PHRASE_WITH_ANIM_LEN_THRESHOLD and not is_cutscene() and not is_rest_active() and not is_speak_active()

func speak(states):
	speech_states = states
	speech_idx = 0
	set_transition_lips(0)
	if can_do_speak_shot():
		do_speak_shot(get_shot_idx(speak_shots_max))
	speech_timer.start()

func stop_speaking():
	if not speech_timer.is_stopped():
		speech_timer.stop()
	speech_states.clear()
	speech_idx = 0
	set_transition_lips(0)

func speak_text(phonetic, audio_length):
	var states = []
	var words = phonetic.split(" ", false)
	for word in words:
		var bigrams = word.bigrams()
		if bigrams.size() == 0:
			if word.length() == 1:
				var tw = get_lips_transition_by_phoneme(word)
				if tw == 0:
					print("WARN: error recognizing phonetic for word %s" % word)
				states.append(tw)
			else:
				print("ERROR: word %s cannot be split to bigrams!")
		var i = 0
		var bs = bigrams.size()
		while i < bs:
			var bigram = bigrams[i]
			i = i + 1
			var last = (bs == i)
			var t = get_lips_transition_by_phoneme(bigram)
			var split = (t == -1)
			if split:
				t = get_lips_transition_by_phoneme(bigram[0])
				if t == -1:
					print("WARN: error recognizing phonetic %s/%s for word %s" % [bigram[0], bigram, word])
				else:
					states.append(t)
			else:
				states.append(t)
			if split and last:
				t = get_lips_transition_by_phoneme(bigram[1])
				if t == -1:
					print("WARN: error recognizing phonetic %s/%s for word %s" % [bigram, bigram[1], word])
				else:
					states.append(t)
		#states.append(0)
	var phoneme_time = audio_length / float(states.size())
	phoneme_time = floor(phoneme_time * 100) / 100.0
	speech_timer.wait_time = phoneme_time
	speak(states)

func _process(delta):
	pass

func _on_SpeechTimer_timeout():
	if speech_idx < speech_states.size():
		set_transition_lips(speech_states[speech_idx])
		speech_idx = speech_idx + 1
		speech_timer.start()
	else:
		stop_speaking()

func _on_RestTimer_timeout():
	do_rest_shot(get_shot_idx(rest_shots_max))
