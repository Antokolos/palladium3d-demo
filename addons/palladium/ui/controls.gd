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

var last_selected_label = null

func set_key_text(control, act):
	if act is InputEventKey:
		control.get_node("Label").set_text(act.as_text())

func set_joypad_text(control, act):
	if act is InputEventJoypadButton:
		var button_index = act.get_button_index()
		control.get_node("Label").set_text(common_utils.joy_button_to_string(button_index))
	if act is InputEventJoypadMotion:
		var axis = act.get_axis()
		var axis_value = act.get_axis_value()
		control.get_node("Label").set_text(common_utils.joy_axis_to_string(axis, axis_value))

func set_mouse_button_text(control, act):
	if act is InputEventMouseButton:
		var button_index = act.get_button_index()
		control.get_node("Label").set_text(common_utils.mouse_button_to_string(button_index))

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

func _on_label_gui_input(event : InputEvent, action_name, action_key, input_types, label_container):
	if event is InputEventMouseMotion:
		var label = label_container.get_node("Label")
		if not last_selected_label \
			or last_selected_label.get_instance_id() != label.get_instance_id():
			if last_selected_label:
				last_selected_label.set("custom_colors/font_color", Color.white)
			last_selected_label = label
			label.set("custom_colors/font_color", Color.red)
	elif event.is_action_pressed("action"):
		$input_dialog.show_input_dialog(self, action_name, action_key, input_types)

func refresh():
	last_selected_label = null
	for ch in controls.get_children():
		if ch.is_connected(
			"gui_input",
			self,
			"_on_label_gui_input"
		):
			ch.disconnect(
				"gui_input",
				self,
				"_on_label_gui_input"
			)
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
		label_key_new.connect(
			"gui_input",
			self,
			"_on_label_gui_input",
			[action, action_key, [ PLDSettings.InputType.KEY ], label_key_new]
		)
		var label_joy_new = label_joy.duplicate(0)
		label_joy_new.connect(
			"gui_input",
			self,
			"_on_label_gui_input",
			[action, action_key, [ PLDSettings.InputType.JOYPAD_BUTTON, PLDSettings.InputType.JOYPAD_MOTION ], label_joy_new]
		)
		var label_mouse_button_new = label_mouse_button.duplicate(0)
		label_mouse_button_new.connect(
			"gui_input",
			self,
			"_on_label_gui_input",
			[action, action_key, [ PLDSettings.InputType.MOUSE_BUTTON ], label_mouse_button_new]
		)
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
