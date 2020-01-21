extends Spatial
class_name PalladiumCharacter

const REST_POSE_CHANGE_TIME_S = 7
const PHRASE_WITH_ANIM_LEN_THRESHOLD = 10

export var look_anim_name = "female_rest_99"
export var walk_anim_name = "female_walk_2"

export var b0_anim_name = "b0"
export var b1_anim_name = "b1"
export var b2_anim_name = "b2"
export var b3_anim_name = "b3"
export var b4_anim_name = "b4"
export var b5_anim_name = "b5"
export var b6_anim_name = "b6"
export var b7_anim_name = "b7"
export var b8_anim_name = "b8"
export var b9_anim_name = "b9"
export var b10_anim_name = "b10"
export var b11_anim_name = "b11"
export var b12_anim_name = "b12"
export var b13_anim_name = "b13"
export var b14_anim_name = "b14"
export var b15_anim_name = "b15"
export var b16_anim_name = "b16"
export var b17_anim_name = "b17"

var simple_mode = true

onready var speech_timer = get_node("SpeechTimer")

var speech_states = []
var speech_idx = 0

func _ready():
	randomize()

func set_simple_mode(sm):
	simple_mode = sm
	$AnimationTree.active = not simple_mode
	if simple_mode:
		look(0)

func do_rest_shot(shot_idx):
	var look_state = $AnimationTree.get("parameters/LookStateTransition/current")
	var is_active = $AnimationTree.get("parameters/LookShot/active")
	if not is_active and look_state == 0:
		$AnimationTree.set("parameters/RestTransition/current", shot_idx)
		$AnimationTree.set("parameters/LookShot/active", true)

func set_speak_mode(enable):
	$AnimationTree.set("parameters/LookStateTransition/current", 1 if enable else 0)

func do_speak_shot(shot_idx):
	var look_state = $AnimationTree.get("parameters/LookStateTransition/current")
	var is_active = $AnimationTree.get("parameters/LookShot/active")
	if not is_active and look_state == 1:
		$AnimationTree.set("parameters/SpeakTransition/current", shot_idx)
		$AnimationTree.set("parameters/LookShot/active", true)

func stand_up():
	if $AnimationTree.get("parameters/LookTransition/current") != 1:
		$AnimationTree.set("parameters/TimeScaleStandUp/scale", -1)
		$AnimationTree.set("parameters/LookTransition/current", 0)
	$AnimationTree.set("parameters/WalkTransition/current", 0)

func sit_down():
	if $AnimationTree.get("parameters/LookTransition/current") != 3:
		$AnimationTree.set("parameters/LookTransition/current", 2)
	$AnimationTree.set("parameters/WalkTransition/current", 1)

func normalize_angle(look_angle_deg):
	return look_angle_deg if abs(look_angle_deg) < 45.0 else (45.0 if look_angle_deg > 0 else -45.0)

func rotate_head(look_angle_deg):
	$AnimationTree.set("parameters/Blend2_Head/blend_amount", 0.5 + 0.5 * (normalize_angle(look_angle_deg) / 45.0))

func set_transition(t):
	var transition = $AnimationTree.get("parameters/Transition/current")
	if transition != t:
		$AnimationTree.set("parameters/Transition/current", t)
		get_anim_player().play(get_anim_name_by_transition(t))

func set_transition_lips(t):
	var transition = $AnimationTree.get("parameters/Transition_Lips/current")
	if transition != t:
		$AnimationTree.set("parameters/Transition_Lips/current", t)
		get_anim_player().play(get_anim_name_by_transition_lips(t))

func get_anim_player():
	return $AnimationTree.get_node($AnimationTree.get_animation_player())

func get_anim_name_by_transition(t):
	match t:
		0:
			return look_anim_name
		1:
			return walk_anim_name
		_:
			return look_anim_name

func get_anim_name_by_transition_lips(t):
	match t:
		0:
			return b0_anim_name
		1:
			return b1_anim_name
		2:
			return b2_anim_name
		3:
			return b3_anim_name
		4:
			return b4_anim_name
		5:
			return b5_anim_name
		6:
			return b6_anim_name
		7:
			return b7_anim_name
		8:
			return b8_anim_name
		9:
			return b9_anim_name
		10:
			return b10_anim_name
		11:
			return b11_anim_name
		12:
			return b12_anim_name
		13:
			return b13_anim_name
		14:
			return b14_anim_name
		15:
			return b15_anim_name
		16:
			return b16_anim_name
		17:
			return b17_anim_name
		_:
			return b0_anim_name

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

func look(look_angle_deg):
	if not simple_mode:
		rotate_head(look_angle_deg)
	set_transition(0)
	if $RestTimer.is_stopped():
		$RestTimer.start(REST_POSE_CHANGE_TIME_S)

func walk(look_angle_deg):
	if not simple_mode:
		rotate_head(look_angle_deg)
	set_transition(1)
	$RestTimer.stop()

func speak(states):
	speech_states = states
	speech_idx = 0
	set_transition_lips(0)
	if speech_states.size() > PHRASE_WITH_ANIM_LEN_THRESHOLD:
		do_speak_shot(0 if randf() > 0.5 else 1)
	speech_timer.start()

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
	if not simple_mode:
		return
	var player = get_node("../../..")
	if player.is_walking:
		walk(0)
	else:
		look(0)

func _on_SpeechTimer_timeout():
	if speech_idx < speech_states.size():
		set_transition_lips(speech_states[speech_idx])
		speech_idx = speech_idx + 1
		$SpeechTimer.start()
	else:
		speech_states.clear()
		speech_idx = 0
		set_transition_lips(0)

func _on_RestTimer_timeout():
	do_rest_shot(0 if randf() > 0.5 else 1)
	$RestTimer.start(REST_POSE_CHANGE_TIME_S)
