extends Spatial
class_name PalladiumCharacter

signal cutscene_finished(player, cutscene_id)

const CUTSCENE_EMPTY = 0

const FEMALE_CUTSCENE_SITTING_STUMP = 1
const FEMALE_CUTSCENE_STAND_UP_STUMP = 2
const FEMALE_TAKES_APATA = 3

const BANDIT_CUTSCENE_PUSHES_CHEST_START = 1

const PLAYER_CUTSCENE_PUSHES_CHEST = 1

const LOOK_TRANSITION_STAND_UP = 0
const LOOK_TRANSITION_STANDING = 1
const LOOK_TRANSITION_SIT_DOWN = 2
const LOOK_TRANSITION_SQUATTING = 3

const TRANSITION_LOOK = 0
const TRANSITION_WALK = 1
const TRANSITION_RUN = 2
const TRANSITION_CROUCH = 3

const REST_POSE_CHANGE_TIME_S = 7
const PHRASE_WITH_ANIM_LEN_THRESHOLD = 10

export var main_skeleton = "Female_palladium_armature"

export var rest_shots_max = 2
export var speak_shots_max = 2

var simple_mode = true

onready var speech_timer = get_node("SpeechTimer")

var speech_states = []
var speech_idx = 0

func _ready():
	randomize()
	game_params.connect("item_taken", self, "_on_item_taken")

func _on_item_taken(nam, count):
	if main_skeleton == "Female_palladium_armature" and game_params.story_vars.apata_trap_stage == game_params.ApataTrapStages.ARMED: # Apply only to female model and only when the trap is still armed
		if nam == "statue_apata":
			var att = get_node("Female_palladium_armature/RightHandAttachment/Position3D")
			var item = load("res://assets/statue_4.escn").instance() #load(game_params.ITEMS[nam].model_path).instance()
			item.set_scale(Vector3(8, 8, 8))
			att.add_child(item)

func remove_item_from_hand():
	var att = get_node("Female_palladium_armature/RightHandAttachment/Position3D")
	for ch in att.get_children():
		att.remove_child(ch)
		ch.queue_free()

func toggle_head(enable):
	var sk = get_node(main_skeleton)
	for m in sk.get_children():
		if m is MeshInstance:
			if m.get_layer_mask_bit(1):
				m.set_layer_mask_bit(0, enable)

func set_simple_mode(sm):
	simple_mode = sm
	toggle_head(not sm)
	if simple_mode:
		look(0)

func do_rest_shot(shot_idx):
	if not is_rest_active() and not is_in_speak_mode() and not is_sitting():
		$AnimationTree.set("parameters/RestTransition/current", shot_idx)
		$AnimationTree.set("parameters/RestShot/active", true)

func stop_rest_shot():
	$AnimationTree.set("parameters/RestShot/active", false)

func is_rest_active():
	return $AnimationTree.get("parameters/RestShot/active")

func is_in_speak_mode():
	return conversation_manager.conversation_is_in_progress()

func do_speak_shot(shot_idx):
	if not is_rest_active() and is_in_speak_mode():
		$AnimationTree.set("parameters/SpeakTransition/current", shot_idx)
		$AnimationTree.set("parameters/SpeakShot/active", true)

func stop_speak_shot():
	$AnimationTree.set("parameters/SpeakShot/active", false)

func play_cutscene(cutscene_id):
	$AnimationTree.set("parameters/CutsceneTransition/current", cutscene_id)
	$AnimationTree.set("parameters/CutsceneShot/active", true)

func stop_cutscene():
	$AnimationTree.set("parameters/CutsceneTransition/current", CUTSCENE_EMPTY)
	$AnimationTree.set("parameters/CutsceneShot/active", false)

func is_cutscene():
	var cutscene_empty = $AnimationTree.get("parameters/CutsceneTransition/current") == CUTSCENE_EMPTY
	return not cutscene_empty and $AnimationTree.get("parameters/CutsceneShot/active")

func is_standing():
	return $AnimationTree.get("parameters/LookTransition/current") == LOOK_TRANSITION_STANDING

func is_sitting():
	return $AnimationTree.get("parameters/LookTransition/current") == LOOK_TRANSITION_SQUATTING

func stand_up():
	if not is_standing():
		$AnimationTree.set("parameters/LookTransition/current", LOOK_TRANSITION_STAND_UP)

func sit_down():
	if not is_sitting():
		$AnimationTree.set("parameters/LookTransition/current", LOOK_TRANSITION_SIT_DOWN)

func normalize_angle(look_angle_deg):
	return look_angle_deg if abs(look_angle_deg) < 45.0 else (45.0 if look_angle_deg > 0 else -45.0)

func rotate_head(look_angle_deg):
	$AnimationTree.set("parameters/Blend2_Head/blend_amount", 0.5 + 0.5 * (normalize_angle(look_angle_deg) / 45.0))

func set_transition(t):
	var transition = $AnimationTree.get("parameters/Transition/current")
	if transition != t:
		$AnimationTree.set("parameters/Transition/current", t)

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

func look(look_angle_deg):
	rotate_head(look_angle_deg)
	set_transition(TRANSITION_LOOK)
	if not is_rest_active() and not is_in_speak_mode() and $RestTimer.is_stopped():
		$RestTimer.start(REST_POSE_CHANGE_TIME_S)

func walk(look_angle_deg, is_crouching = false, is_sprinting = false):
	rotate_head(look_angle_deg)
	set_transition(TRANSITION_CROUCH if is_crouching else (TRANSITION_RUN if is_sprinting else TRANSITION_WALK))
	$RestTimer.stop()
	stop_speak_shot()
	stop_rest_shot()

func speak(states):
	speech_states = states
	speech_idx = 0
	set_transition_lips(0)
	if speak_shots_max > 0 and speech_states.size() > PHRASE_WITH_ANIM_LEN_THRESHOLD:
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
	if not simple_mode:
		if not is_cutscene():
			var cutscene_id = $AnimationTree.get("parameters/CutsceneTransition/current")
			if cutscene_id > CUTSCENE_EMPTY:
				var player = get_node("../..")
				emit_signal("cutscene_finished", player, cutscene_id)
		return

func _on_SpeechTimer_timeout():
	if speech_idx < speech_states.size():
		set_transition_lips(speech_states[speech_idx])
		speech_idx = speech_idx + 1
		speech_timer.start()
	else:
		stop_speaking()

func get_shot_idx(shots_max):
	var shot_span = 1.0 / shots_max
	var shot_idx = int(floor(randf() / shot_span))
	if shot_idx == shots_max:
		shot_idx = shot_idx - 1
	return shot_idx

func _on_RestTimer_timeout():
	do_rest_shot(get_shot_idx(rest_shots_max))
