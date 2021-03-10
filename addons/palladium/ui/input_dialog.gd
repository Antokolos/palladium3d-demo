extends WindowDialog

const AXIS_VALUE_THRESHOLD = 0.15

onready var test_button = get_node("VBoxContainer/TestButton")
onready var apply_button = get_node("VBoxContainer/HBoxContainer/ApplyButton")
onready var cancel_button = get_node("VBoxContainer/HBoxContainer/CancelButton")
onready var clear_button = get_node("VBoxContainer/HBoxContainer/ClearButton")
onready var label_action_name = get_node("VBoxContainer/LabelActionName")
onready var label_what_to_do = get_node("VBoxContainer/LabelWhatToDo")
onready var label_result = get_node("VBoxContainer/LabelResult")

var controls_app = null
var action_name = null
var input_types = []
var captured_event = null

func _ready():
	get_close_button().connect("pressed", self, "_on_CancelButton_pressed")

func show_input_dialog(controls_app, action_name, action_key, input_types):
	self.controls_app = controls_app
	self.action_name = action_name
	self.input_types = input_types
	label_action_name.text = tr(action_key)
	label_what_to_do.text = get_what_to_do_text(input_types)
	disable_buttons()
	captured_event = null
	label_result.text = ""
	popup_centered_ratio(0.5)

func _notification(what):
	match what:
		NOTIFICATION_POST_POPUP:
			#Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE) #TODO: check it is neeeded
			test_button.grab_focus()

func get_what_to_do_text(itypes):
	for itype in itypes:
		match itype:
			PLDSettings.InputType.KEY:
				return tr("DIALOG_INPUT_KEY")
			PLDSettings.InputType.JOYPAD_BUTTON, PLDSettings.InputType.JOYPAD_MOTION:
				return tr("DIALOG_INPUT_JOY")
			PLDSettings.InputType.MOUSE_BUTTON:
				return tr("DIALOG_INPUT_MOUSE")
	return ""

func enable_buttons():
	apply_button.disabled = false
	cancel_button.disabled = false
	if action_name != "action":
		clear_button.disabled = false

func disable_buttons():
	apply_button.disabled = true
	cancel_button.disabled = true
	clear_button.disabled = true

func _input(event):
	if not visible:
		return
	if event.is_action_pressed("ui_tablet_toggle"):
		_on_CancelButton_pressed()
	elif not captured_event and event.is_pressed():
		get_tree().set_input_as_handled()
		for input_type in input_types:
			match input_type:
				PLDSettings.InputType.KEY:
					if event is InputEventKey:
						captured_event = event
						label_result.text = event.as_text()
						enable_buttons()
				PLDSettings.InputType.JOYPAD_BUTTON:
					if event is InputEventJoypadButton:
						captured_event = event
						label_result.text = common_utils.joy_button_to_string(event.get_button_index())
						enable_buttons()
				PLDSettings.InputType.JOYPAD_MOTION:
					if event is InputEventJoypadMotion:
						var a = event.get_axis()
						if a == JOY_AXIS_6 or a == JOY_AXIS_7:
							# Joypad Right Trigger Analog Axis
							# OR
							# Joypad Left Trigger Analog Axis
							return
						var v = event.get_axis_value()
						if v > AXIS_VALUE_THRESHOLD or v < -AXIS_VALUE_THRESHOLD:
							captured_event = event
							label_result.text = common_utils.joy_axis_to_string(a, v)
							enable_buttons()
				PLDSettings.InputType.MOUSE_BUTTON:
					if event is InputEventMouseButton:
						captured_event = event
						label_result.text = common_utils.mouse_button_to_string(event.get_button_index())
						enable_buttons()

func _on_ApplyButton_pressed():
	if captured_event:
		for input_type in input_types:
			settings.erase_action_event_of_type(action_name, input_type)
		InputMap.action_add_event(action_name, captured_event)
	close_input_dialog()

func _on_CancelButton_pressed():
	close_input_dialog()

func _on_ClearButton_pressed():
	for input_type in input_types:
		settings.erase_action_event_of_type(action_name, input_type)
	close_input_dialog()

func close_input_dialog():
	disable_buttons()
	action_name = null
	input_types.clear()
	captured_event = null
	label_result.text = ""
	visible = false
	if controls_app:
		controls_app.refresh()
		controls_app = null
