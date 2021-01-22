extends Spatial

signal crouching_changed(player_node, previous_state, new_state)
signal cutscene_finished(player, player_model, cutscene_id, was_active)

const PHRASE_WITH_ANIM_LEN_THRESHOLD = 10

export var speak_shots_max = 2

onready var speech_timer = $SpeechTimer
onready var should_check_cutscene = true

var speech_states = []
var speech_idx = 0

var name_hint = CHARS.PLAYER_NAME_HINT

func _ready():
	game_state.register_player(self)

func set_look_transition(force = false):
	pass

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

func set_transition_lips(t):
	var transition = $AnimationTree.get("parameters/Transition_Lips/current")
	if transition != t:
		$AnimationTree.set("parameters/Transition_Lips/current", t)

func speak(states):
	speech_states = states
	speech_idx = 0
	set_transition_lips(0)
	if speech_states.size() > PHRASE_WITH_ANIM_LEN_THRESHOLD:
		do_speak_shot(get_shot_idx(speak_shots_max))
	speech_timer.start()

func do_speak_shot(shot_idx):
	pass

func get_shot_idx(shots_max):
	var shot_span = 1.0 / shots_max
	var shot_idx = int(floor(randf() / shot_span))
	if shot_idx == shots_max:
		shot_idx = shot_idx - 1
	return shot_idx

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

func _on_SpeechTimer_timeout():
	if speech_idx < speech_states.size():
		set_transition_lips(speech_states[speech_idx])
		speech_idx = speech_idx + 1
		speech_timer.start()
	else:
		stop_speaking()

func _input(event):
	var hud = game_state.get_hud()
	var conversation = hud.conversation
	if conversation.is_visible_in_tree():
		if event.is_action_pressed("dialogue_next"):
			conversation_manager.proceed_story_immediately(self)
		elif event.is_action_pressed("dialogue_option_1"):
			conversation_manager.story_choose(self, 0)
		elif event.is_action_pressed("dialogue_option_2"):
			conversation_manager.story_choose(self, 1)
		elif event.is_action_pressed("dialogue_option_3"):
			conversation_manager.story_choose(self, 2)
		elif event.is_action_pressed("dialogue_option_4"):
			conversation_manager.story_choose(self, 3)

func get_name_hint():
	return name_hint

func get_cam():
	return get_node("../camera_intro/Camera")

func get_model():
	return self

func is_hidden():
	return false

func is_crouching():
	return false

func stop_cutscene():
	pass

func reset_movement():
	pass

func start():
	$AnimationTree.active = true
	walks_intro()

func walks_intro():
	$AnimationTree.set("parameters/Transition/current", 0)

func walks_room():
	$AnimationTree.set("parameters/Transition/current", 2)

func _process(delta):
	if should_check_cutscene and $AnimationTree.get("parameters/Transition/current") == 3:
		should_check_cutscene = false
		emit_signal("cutscene_finished", self, self, 0, false)