extends ViewportContainer
class_name PLDGameWindow

func _input(event):
	if do_input(event) > 1:
		get_tree().set_input_as_handled()

func do_input(event):
	if common_utils.has_joypads() and event is InputEventMouseMotion:
		return 2
	if common_utils.is_mouse_captured():
		var is_joy_motion = event is InputEventJoypadMotion
		if not is_joy_motion:
			return 0
		elif is_joy_motion and event.get_axis() == JOY_AXIS_6: # Joypad Left Trigger Analog Axis
			return 2
		elif is_joy_motion and event.get_axis() == JOY_AXIS_7: # Joypad Right Trigger Analog Axis
			return 2
		else:
			return 0
	if not event is InputEventMouseButton \
		and (event.is_action_pressed("action") or event.is_action_pressed("ui_accept")):
		if not get_tree().paused \
			or game_state.get_hud().is_tablet_visible() \
			or game_state.get_hud().is_quit_dialog_visible():
			click_the_left_mouse_button()
	return 1

func click_the_left_mouse_button():
	var evt = InputEventMouseButton.new()
	evt.factor = 1
	evt.button_index = BUTTON_LEFT
	evt.button_mask = BUTTON_MASK_LEFT
	evt.position = get_viewport().get_mouse_position()
	evt.global_position = evt.position
	evt.pressed = true
	get_tree().input_event(evt)
	evt.pressed = false
	get_tree().input_event(evt)