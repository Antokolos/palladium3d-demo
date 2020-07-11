extends ViewportContainer
class_name PLDGameWindow

const AXIS_VALUE_THRESHOLD = 0.15
const MOUSE_SENSITIVITY = 30

onready var rel_pos = Vector2(0, 0)
onready var viewport = get_viewport()

var in_focus = true

func _input(event):
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		return
	if event is InputEventJoypadMotion:
		var v = event.get_axis_value()
		var nonzero = v > AXIS_VALUE_THRESHOLD or v < -AXIS_VALUE_THRESHOLD
		if event.get_axis() == JOY_AXIS_2:  # Joypad Right Stick Horizontal Axis
			rel_pos.x = MOUSE_SENSITIVITY * v if nonzero else 0
		if event.get_axis() == JOY_AXIS_3:  # Joypad Right Stick Vertical Axis
			rel_pos.y = MOUSE_SENSITIVITY * v if nonzero else 0
	if not event is InputEventMouseButton \
		and event.is_action_pressed("action") \
		and (not get_tree().paused or game_params.get_hud().is_tablet_visible()):
		click_the_left_mouse_button()

func _notification(what):
	match what:
		MainLoop.NOTIFICATION_WM_FOCUS_IN:
		# the game window just received focus from the operating system
			in_focus = true
		MainLoop.NOTIFICATION_WM_FOCUS_OUT:
		# the game window just lost focus from the operating system
			in_focus = false

func _process(delta):
	if not in_focus:
		return
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		return
	var mouse_pos = viewport.get_mouse_position()
	mouse_pos = mouse_pos + rel_pos
	viewport.warp_mouse(mouse_pos)

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