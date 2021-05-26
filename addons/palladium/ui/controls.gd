extends Panel

const COLOR_MODULATE = Color(0.1, 0.1, 0.1)
const NA = "N/A"

onready var input_actions = get_node("VBoxContainer/GridContainer")
onready var label_action = input_actions.get_node("LabelAction")
onready var label_key = input_actions.get_node("LabelKey")
onready var label_joy = input_actions.get_node("LabelJoy")
onready var label_mouse_button = input_actions.get_node("LabelMouseButton")
onready var scroll_container = get_node("VBoxContainer/HInputActions/ScrollContainer")
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

func select_label(label_container):
	var label = label_container.get_node("Label") if label_container else null
	if not last_selected_label \
		or not label \
		or last_selected_label.get_instance_id() != label.get_instance_id():
		if last_selected_label:
			last_selected_label.set("custom_colors/font_color", Color.white)
		last_selected_label = label
		if label:
			label.set("custom_colors/font_color", Color.red)

func remove_selection(label_container):
	var label = label_container.get_node("Label") if label_container else null
	if label:
		label.set("custom_colors/font_color", Color.white)
		if last_selected_label and last_selected_label.get_instance_id() == label.get_instance_id():
			last_selected_label = null

func _on_label_gui_input(event : InputEvent, action_name, action_key, input_types, label_container):
	if event is InputEventMouseMotion:
		select_label(label_container)
	elif event.is_action_pressed("action"):
		$input_dialog.show_input_dialog(self, action_name, action_key, input_types)

func _on_focus_entered(label_container):
	select_label(label_container)
	var focus_size = label_container.rect_size.y
	var focus_top = label_container.rect_position.y
	
	var scroll_size = scroll_container.rect_size.y
	var scroll_top = scroll_container.get_v_scroll()
	var scroll_bottom = scroll_top + scroll_size - focus_size
	
	if focus_top < scroll_top:
		scroll_container.set_v_scroll(focus_top)
	
	if focus_top > scroll_bottom:
		var scroll_offset = scroll_top + focus_top - scroll_bottom
		scroll_container.set_v_scroll(scroll_offset)

func _on_focus_exited(label_container):
	remove_selection(label_container)

func refresh():
	var label_to_select = null
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
		if ch.is_connected(
			"focus_entered",
			self,
			"_on_focus_entered"
		):
			ch.disconnect(
				"focus_entered",
				self,
				"_on_focus_entered"
			)
		if ch.is_connected(
			"focus_exited",
			self,
			"_on_focus_exited"
		):
			ch.disconnect(
				"focus_exited",
				self,
				"_on_focus_exited"
			)
		if ch.is_connected(
			"mouse_exited",
			self,
			"_on_focus_exited"
		):
			ch.disconnect(
				"mouse_exited",
				self,
				"_on_focus_exited"
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
		if not label_to_select:
			label_to_select = label_key_new
		label_key_new.connect(
			"gui_input",
			self,
			"_on_label_gui_input",
			[action, action_key, [ PLDSettings.InputType.KEY ], label_key_new]
		)
		label_key_new.connect(
			"focus_entered",
			self,
			"_on_focus_entered",
			[label_key_new]
		)
		label_key_new.connect(
			"focus_exited",
			self,
			"_on_focus_exited",
			[label_key_new]
		)
		label_key_new.connect(
			"mouse_exited",
			self,
			"_on_focus_exited",
			[label_key_new]
		)
		var label_joy_new = label_joy.duplicate(0)
		label_joy_new.connect(
			"gui_input",
			self,
			"_on_label_gui_input",
			[action, action_key, [ PLDSettings.InputType.JOYPAD_BUTTON, PLDSettings.InputType.JOYPAD_MOTION ], label_joy_new]
		)
		label_joy_new.connect(
			"focus_entered",
			self,
			"_on_focus_entered",
			[label_joy_new]
		)
		label_joy_new.connect(
			"focus_exited",
			self,
			"_on_focus_exited",
			[label_joy_new]
		)
		label_joy_new.connect(
			"mouse_exited",
			self,
			"_on_focus_exited",
			[label_joy_new]
		)
		var label_mouse_button_new = label_mouse_button.duplicate(0)
		label_mouse_button_new.connect(
			"gui_input",
			self,
			"_on_label_gui_input",
			[action, action_key, [ PLDSettings.InputType.MOUSE_BUTTON ], label_mouse_button_new]
		)
		label_mouse_button_new.connect(
			"focus_entered",
			self,
			"_on_focus_entered",
			[label_mouse_button_new]
		)
		label_mouse_button_new.connect(
			"focus_exited",
			self,
			"_on_focus_exited",
			[label_mouse_button_new]
		)
		label_mouse_button_new.connect(
			"mouse_exited",
			self,
			"_on_focus_exited",
			[label_mouse_button_new]
		)
		if need_modulate:
			label_action_new.set_self_modulate(COLOR_MODULATE)
			label_key_new.set_self_modulate(COLOR_MODULATE)
			label_joy_new.set_self_modulate(COLOR_MODULATE)
			label_mouse_button_new.set_self_modulate(COLOR_MODULATE)
		need_modulate = not need_modulate
		controls.add_child(label_action_new)
		label_key_new.set_focus_mode(FOCUS_ALL)
		controls.add_child(label_key_new)
		label_joy_new.set_focus_mode(FOCUS_ALL)
		controls.add_child(label_joy_new)
		label_mouse_button_new.set_focus_mode(FOCUS_ALL)
		controls.add_child(label_mouse_button_new)
		label_action_new.get_node("Label").set_text(tr(action_key))
		label_key_new.get_node("Label").set_text(NA)
		label_joy_new.get_node("Label").set_text(NA)
		label_mouse_button_new.get_node("Label").set_text(NA)
		for act in list:
			set_key_text(label_key_new, act)
			set_joypad_text(label_joy_new, act)
			set_mouse_button_text(label_mouse_button_new, act)
	select_label(label_to_select)
	label_to_select.grab_focus()