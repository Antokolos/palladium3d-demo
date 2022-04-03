extends Node2D

const AXIS_VALUE_THRESHOLD = 0.15
const JOY_SENSITIVITY = 30

onready var cursor_normal = $cursor_normal
onready var viewport = game_state.get_viewport()
onready var rel_pos = Vector2(0, 0) setget set_rel_pos, get_rel_pos

var in_focus = true
var warping_mutex : Mutex = Mutex.new()

func _ready():
	Input.connect("joy_connection_changed", self, "_on_joy_connection_changed")
	common_utils.connect("mouse_mode_changed", self, "_on_mouse_mode_changed")
	warp_mouse(viewport.get_mouse_position())

func _on_joy_connection_changed(device_id, is_connected):
	if not is_connected:
		if not settings.pause_on_joy_disconnected:
			return
		warp_mouse_in_center()

func _on_mouse_mode_changed(mouse_mode):
	match mouse_mode:
		Input.MOUSE_MODE_VISIBLE:
			cursor_normal.visible = true
		_:
			cursor_normal.visible = false

func click_the_left_mouse_button():
	var evt = InputEventMouseButton.new()
	evt.factor = 1
	evt.button_index = BUTTON_LEFT
	evt.button_mask = BUTTON_MASK_LEFT
	evt.position = get_mouse_position()
	evt.global_position = evt.position
	evt.pressed = true
	get_tree().input_event(evt)
	evt.pressed = false
	get_tree().input_event(evt)

func warp_mouse(position):
	warping_mutex.lock()
	var r = viewport.get_visible_rect()
	var ov = OS.get_window_size()
	var p = position
	var xmin = r.position.x
	var xmax = r.position.x + ov.x
	var ymin = r.position.y
	var ymax = r.position.y + ov.y
	if p.x < xmin:
		p.x = xmin
	if p.x > xmax:
		p.x = xmax
	if p.y < ymin:
		p.y = ymin
	if p.y > ymax:
		p.y = ymax
	cursor_normal.position = p
	viewport.warp_mouse(p)
	warping_mutex.unlock()

func warp_mouse_in_center():
	warp_mouse(Vector2(OS.window_size.x / 2, OS.window_size.y / 2))

func set_rel_pos(rpos):
	rel_pos = rpos

func set_rel_pos_x(x):
	rel_pos.x = x

func set_rel_pos_y(y):
	rel_pos.y = y

func get_rel_pos():
	return rel_pos

func has_no_rel_pos():
	return rel_pos.x == 0 and rel_pos.y == 0

func get_mouse_position():
	return cursor_normal.position

func _notification(what):
	match what:
		MainLoop.NOTIFICATION_WM_FOCUS_IN:
		# the game window just received focus from the operating system
			in_focus = true
		MainLoop.NOTIFICATION_WM_FOCUS_OUT:
		# the game window just lost focus from the operating system
			in_focus = false

func _input(event):
	if not in_focus or common_utils.is_mouse_captured():
		return
	if event is InputEventJoypadMotion:
		var v = event.get_axis_value()
		var nonzero = v > AXIS_VALUE_THRESHOLD or v < -AXIS_VALUE_THRESHOLD
		if event.get_axis() == JOY_AXIS_2:  # Joypad Right Stick Horizontal Axis
			set_rel_pos_x(JOY_SENSITIVITY * v if nonzero else 0)
		if event.get_axis() == JOY_AXIS_3:  # Joypad Right Stick Vertical Axis
			set_rel_pos_y(JOY_SENSITIVITY * v if nonzero else 0)
	elif has_no_rel_pos() and event is InputEventMouseMotion:
		cursor_normal.position = viewport.get_mouse_position()

func _process(delta):
	if warping_mutex.try_lock() == ERR_BUSY:
		return
	if not in_focus or common_utils.is_mouse_captured():
		return
	if has_no_rel_pos():
		return
	var mouse_pos = get_mouse_position()
	mouse_pos = mouse_pos + rel_pos
	warp_mouse(mouse_pos)