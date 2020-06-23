extends Spatial

export(int) var correct_state = 0

func _ready():
	restore_state()

func use(player_node, camera_node):
	var state = $AnimationTree.get("parameters/Transition/current")
	var new_state = state + 1 if state < 3 else 1
	$AnimationTree.set("parameters/Transition/current", new_state)
	game_params.set_multistate_state(get_path(), new_state)
	$SoundRotation.play()

func is_state_correct():
	var state = $AnimationTree.get("parameters/Transition/current")
	if state == 0:
		state = 3
	return state == correct_state

func add_highlight(player_node):
	return "E: " + tr("ACTION_TURN")

func remove_highlight(player_node):
	pass

func restore_state():
	$AnimationTree.active = true
	var state = game_params.get_multistate_state(get_path())
	$AnimationTree.set("parameters/Transition/current", state)

func _on_SoundRotation_finished():
	if is_state_correct():
		$SoundCorrectPos.play()
	else:
		$SoundIncorrectPos.play()
