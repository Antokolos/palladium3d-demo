extends Panel

const COLOR_MODULATE = Color(0.1, 0.1, 0.1)
const SCROLL_STEP = 40

onready var input_actions = get_node("VBoxContainer/GridContainer")
onready var label_action = input_actions.get_node("LabelAction")
onready var label_key = input_actions.get_node("LabelKey")
onready var label_joy = input_actions.get_node("LabelJoy")
onready var label_mouse_button = input_actions.get_node("LabelMouseButton")
onready var scroll_container = get_node("VBoxContainer/HInputActions/ScrollContainer")
onready var scrollbar = scroll_container.get_v_scrollbar()
onready var controls = scroll_container.get_node("GridContainer")

func set_key_text(control, act):
	if act is InputEventKey:
		control.get_node("Label").set_text(act.as_text())

func joy_button_to_string(button_index):
	match button_index:
		JOY_XBOX_A, JOY_SONY_X, JOY_DS_B:
			return "XBOX A | PS X | Nintendo B"
		JOY_XBOX_B, JOY_SONY_CIRCLE, JOY_DS_A:
			return "XBOX B | PS circle | Nintendo A"
		JOY_XBOX_X, JOY_SONY_SQUARE, JOY_DS_Y:
			return "XBOX X | PS square | Nintendo Y"
		JOY_XBOX_Y, JOY_SONY_TRIANGLE, JOY_DS_X:
			return "XBOX Y | PS triangle | Nintendo X"
		JOY_L:
			return "Joypad Left Shoulder Button"
		JOY_R:
			return "Joypad Right Shoulder Button"
		JOY_L2:
			return "Joypad Left Trigger"
		JOY_R2:
			return "Joypad Right Trigger"
		JOY_L3:
			return "Joypad Left Stick Click"
		JOY_R3:
			return "Joypad Right Stick Click"
		JOY_SELECT:
			return "Joypad Button Select, Nintendo -"
		JOY_START:
			return "Joypad Button Start, Nintendo +"
		JOY_DPAD_UP:
			return "Joypad DPad Up"
		JOY_DPAD_DOWN:
			return "Joypad DPad Down"
		JOY_DPAD_LEFT:
			return "Joypad DPad Left"
		JOY_DPAD_RIGHT:
			return "Joypad DPad Right"
		_:
			return "Joypad Button"

func joy_axis_to_string(axis, axis_value):
	match axis:
		JOY_AXIS_0:  # Joypad Left Stick Horizontal Axis
			return "Left Stick " + ("Left" if axis_value < 0 else "Right")
		JOY_AXIS_1:  # Joypad Left Stick Vertical Axis
			return "Left Stick " + ("Up" if axis_value < 0 else "Down")
		JOY_AXIS_2:  # Joypad Right Stick Horizontal Axis
			return "Right Stick " + ("Left" if axis_value < 0 else "Right")
		JOY_AXIS_3:  # Joypad Right Stick Vertical Axis
			return "Right Stick " + ("Up" if axis_value < 0 else "Down")
	return "Stick " + ("-" if axis_value < 0 else "+")

func mouse_button_to_string(button_index):
	match button_index:
		BUTTON_LEFT:
			return "Left Mouse Button"
		BUTTON_RIGHT:
			return "Right Mouse Button"
		BUTTON_MIDDLE:
			return "Middle Mouse Button"

func set_joypad_text(control, act):
	if act is InputEventJoypadButton:
		var button_index = act.get_button_index()
		control.get_node("Label").set_text(joy_button_to_string(button_index))
	if act is InputEventJoypadMotion:
		var axis = act.get_axis()
		var axis_value = act.get_axis_value()
		control.get_node("Label").set_text(joy_axis_to_string(axis, axis_value))

func set_mouse_button_text(control, act):
	if act is InputEventMouseButton:
		var button_index = act.get_button_index()
		control.get_node("Label").set_text(mouse_button_to_string(button_index))

func _input(event):
	if not scroll_container.is_visible_in_tree():
		return
	if event.is_action_pressed("ui_down") or event.is_action_pressed("ui_page_down"):
		var smax = scrollbar.get_max()
		scroll_container.scroll_vertical = scroll_container.scroll_vertical + SCROLL_STEP
		if scroll_container.scroll_vertical > smax:
			scroll_container.scroll_vertical = smax
		scroll_container.update()
	elif event.is_action_pressed("ui_up") or event.is_action_pressed("ui_page_up"):
		scroll_container.scroll_vertical = scroll_container.scroll_vertical - SCROLL_STEP
		if scroll_container.scroll_vertical < 0:
			scroll_container.scroll_vertical = 0
		scroll_container.update()

func refresh():
	for ch in controls.get_children():
		ch.queue_free()
	var actions = InputMap.get_actions()
	actions.sort()
	var need_modulate = true
	for action in actions:
		if action.find("ui_") == 0:
			# Do not show standard UI actions
			continue
		var action_key = "INPUT_MAP_%s" % action.to_upper()
		var list = InputMap.get_action_list(action)
		var label_action_new = label_action.duplicate(0)
		var label_key_new = label_key.duplicate(0)
		var label_joy_new = label_joy.duplicate(0)
		var label_mouse_button_new = label_mouse_button.duplicate(0)
		if need_modulate:
			label_action_new.set_self_modulate(COLOR_MODULATE)
			label_key_new.set_self_modulate(COLOR_MODULATE)
			label_joy_new.set_self_modulate(COLOR_MODULATE)
			label_mouse_button_new.set_self_modulate(COLOR_MODULATE)
		need_modulate = not need_modulate
		controls.add_child(label_action_new)
		controls.add_child(label_key_new)
		controls.add_child(label_joy_new)
		controls.add_child(label_mouse_button_new)
		label_action_new.get_node("Label").set_text(tr(action_key))
		label_key_new.get_node("Label").set_text("")
		label_joy_new.get_node("Label").set_text("")
		label_mouse_button_new.get_node("Label").set_text("")
		for act in list:
			set_key_text(label_key_new, act)
			set_joypad_text(label_joy_new, act)
			set_mouse_button_text(label_mouse_button_new, act)