extends PLDUsable
class_name StatuesPostament

export(int) var correct_state = 0

func use(player_node, camera_node):
	var state = $AnimationTree.get("parameters/Transition/current")
	var new_state = state + 1 if state < 3 else 1
	$AnimationTree.set("parameters/Transition/current", new_state)
	game_state.set_multistate_state(get_path(), new_state)
	$SoundRotation.play()

func get_usage_code(player_node):
	return "ACTION_TURN"

func is_state_correct():
	var state = $AnimationTree.get("parameters/Transition/current")
	if state == 0:
		state = 3
	return state == correct_state

func restore_state():
	$AnimationTree.active = true
	var state = game_state.get_multistate_state(get_path())
	$AnimationTree.set("parameters/Transition/current", state)

func _on_SoundRotation_finished():
	if is_state_correct():
		$SoundCorrectPos.play()
	else:
		$SoundIncorrectPos.play()
