extends PLDCharacterModel
class_name PLDPlayerModel

const PHRASE_WITH_ANIM_LEN_THRESHOLD = 10

export(NodePath) var backpack_animation_player_path = null
export var backpack_speak_animations = {}
export var backpack_rest_animations = {}
export var backpack_cutscene_animations = {}
export var backpack_damage_animations = {}
export var backpack_squats_reversed_anim = ""
export var backpack_squats_anim = ""
export var backpack_squats_rest_anim = ""
export var backpack_crouch_squatted_anim = ""
export var backpack_walk_anim = ""
export var backpack_runs_anim = ""
export var backpack_fall_down_anim = ""

export var speak_shots_max = 2

onready var backpack_animation_player = get_node(backpack_animation_player_path) if backpack_animation_player_path and has_node(backpack_animation_player_path) else null
onready var speech_timer = get_node("SpeechTimer")

var speech_states = []
var speech_idx = 0

func set_simple_mode(sm):
	.set_simple_mode(sm)
	toggle_head(not sm)

func do_rest_shot(shot_idx):
	if .do_rest_shot(shot_idx):
		if backpack_rest_animations.has(shot_idx):
			change_backpack_anim_if_needed(backpack_rest_animations[shot_idx])
		else:
			change_backpack_anim_if_needed(null)
		return true
	return false

func is_speak_active():
	return animation_tree.get("parameters/SpeakShot/active")

func do_speak_shot(shot_idx):
	animation_tree.set("parameters/SpeakTransition/current", shot_idx)
	animation_tree.set("parameters/SpeakShot/active", true)
	if backpack_speak_animations.has(shot_idx):
		change_backpack_anim_if_needed(backpack_speak_animations[shot_idx])
	else:
		change_backpack_anim_if_needed(null)

func stop_speak_shot():
	animation_tree.set("parameters/SpeakShot/active", false)

func play_cutscene(cutscene_id):
	.play_cutscene(cutscene_id)
	if backpack_cutscene_animations.has(cutscene_id):
		change_backpack_anim_if_needed(backpack_cutscene_animations[cutscene_id])
	else:
		change_backpack_anim_if_needed(null)

func take_damage(fatal):
	.take_damage(fatal)
	var anim_idx = 0 if fatal else 2
	if backpack_damage_animations.has(anim_idx):
		change_backpack_anim_if_needed(backpack_damage_animations[anim_idx])
	else:
		change_backpack_anim_if_needed(null)

func set_transition_lips(t):
	animation_tree.set("parameters/Blend2_Lips/blend_amount", 1.0 if t > 0 else 0.0)
	var transition = animation_tree.get("parameters/Transition_Lips/current")
	if transition != t:
		animation_tree.set("parameters/Transition_Lips/current", t)

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

func stand_up():
	if is_standing():
		return false
	change_backpack_anim_if_needed(backpack_squats_reversed_anim)
	return .stand_up()

func sit_down():
	if is_sitting():
		return false
	change_backpack_anim_if_needed(backpack_squats_anim)
	return .sit_down()

func change_backpack_anim_if_needed(animation_to):
	if not backpack_animation_player:
		return false
	var curr_anim_name = backpack_animation_player.get_current_animation()
	if not animation_to or animation_to.empty():
		if backpack_animation_player.is_playing():
			var curr_anim = backpack_animation_player.get_animation(curr_anim_name)
			if curr_anim.has_loop():
				backpack_animation_player.stop()
		return false
	var need_to_change = (
		not backpack_animation_player.is_playing()
		or curr_anim_name != animation_to
	)
	if need_to_change:
		backpack_animation_player.play(animation_to)
	return need_to_change

func look():
	.look()
	if is_sitting():
		change_backpack_anim_if_needed(backpack_squats_rest_anim)
	elif is_standing():
		change_backpack_anim_if_needed(null)

func walk(is_crouching = false, is_sprinting = false):
	.walk(is_crouching, is_sprinting)
	stop_speak_shot()
	play_backpack_walk(is_crouching, is_sprinting)

func fall():
	.fall()
	change_backpack_anim_if_needed(backpack_fall_down_anim)

func play_backpack_walk(is_crouching, is_sprinting):
	if is_crouching:
		change_backpack_anim_if_needed(backpack_crouch_squatted_anim)
	elif is_sprinting:
		change_backpack_anim_if_needed(backpack_runs_anim)
	else: # not is_sprinting
		change_backpack_anim_if_needed(backpack_walk_anim)

func can_do_speak_shot():
	return speak_shots_max > 0 and speech_states.size() > PHRASE_WITH_ANIM_LEN_THRESHOLD and not is_movement_disabled() and not is_rest_active() and not is_speak_active()

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
	if not phonetic or phonetic.empty():
		stop_speaking()
		return
	#print(phonetic)
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
	if states.empty():
		stop_speaking()
		return
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
