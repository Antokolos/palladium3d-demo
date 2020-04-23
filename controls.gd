extends Panel

const COLOR_MODULATE = Color(0.1, 0.1, 0.1)

onready var input_actions = get_node("VBoxContainer/GridContainer")
onready var label_action = input_actions.get_node("LabelAction")
onready var label_key = input_actions.get_node("LabelKey")
onready var label_joy_button = input_actions.get_node("LabelJoyButton")
onready var label_mouse_button = input_actions.get_node("LabelMouseButton")
onready var controls = get_node("VBoxContainer/HInputActions/ScrollContainer/GridContainer")

func set_key_text(control, act):
	if act is InputEventKey:
		control.get_node("Label").set_text(act.as_text())

func set_joypad_button_text(control, act):
	if act is InputEventJoypadButton:
		var button_index = act.get_button_index()
		control.get_node("Label").set_text(str(button_index))

func set_mouse_button_text(control, act):
	if act is InputEventMouseButton:
		var button_index = act.get_button_index()
		control.get_node("Label").set_text(str(button_index))

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
		var label_joy_button_new = label_joy_button.duplicate(0)
		var label_mouse_button_new = label_mouse_button.duplicate(0)
		if need_modulate:
			label_action_new.set_self_modulate(COLOR_MODULATE)
			label_key_new.set_self_modulate(COLOR_MODULATE)
			label_joy_button_new.set_self_modulate(COLOR_MODULATE)
			label_mouse_button_new.set_self_modulate(COLOR_MODULATE)
		need_modulate = not need_modulate
		controls.add_child(label_action_new)
		controls.add_child(label_key_new)
		controls.add_child(label_joy_button_new)
		controls.add_child(label_mouse_button_new)
		label_action_new.get_node("Label").set_text(tr(action_key))
		label_key_new.get_node("Label").set_text("")
		label_joy_button_new.get_node("Label").set_text("")
		label_mouse_button_new.get_node("Label").set_text("")
		for act in list:
			set_key_text(label_key_new, act)
			set_joypad_button_text(label_joy_button_new, act)
			set_mouse_button_text(label_mouse_button_new, act)