extends Control

onready var dimmer = get_node("Dimmer")
onready var tablet = get_node("tablet")

onready var mouse_cursor = get_node("mouse_cursor")
onready var label_joy_hint = get_node("LabelJoyHint")
onready var image_adjust = get_node("ImageAdjust")

func _ready():
	common_utils.show_mouse_cursor_if_needed_in_game(self)
	settings.connect("image_adjust_changed", self, "_on_image_adjust_changed")
	_on_image_adjust_changed(settings.use_image_adjust, settings.brightness, settings.contrast, settings.saturation)
	label_joy_hint.text = tr("MAIN_MENU_JOY_HINT") % common_utils.get_input_control("ui_accept", false)
	label_joy_hint.visible = common_utils.has_joypads()
	Input.connect("joy_connection_changed", self, "_on_joy_connection_changed")

func _on_joy_connection_changed(device_id, is_connected):
	label_joy_hint.visible = common_utils.has_joypads()

func is_menu_hud():
	return true

func is_tablet_visible():
	return tablet.visible

func is_quit_dialog_visible():
	return get_node("quit_dialog").visible

func get_mouse_cursor():
	return mouse_cursor

func pause_game(enable, with_dimmer = true):
	dimmer.visible = with_dimmer and enable
	get_tree().paused = enable

func show_tablet(is_show, activation_mode = PLDTablet.ActivationMode.DESKTOP):
	if is_show:
		common_utils.show_mouse_cursor_if_needed(true)
		pause_game(true)
		tablet.activate(activation_mode)
	else:
		common_utils.show_mouse_cursor_if_needed(true, true)
		tablet.visible = false
		pause_game(false)
		settings.save_settings()
		settings.save_input()

func update_hud():
	pass

func _on_image_adjust_changed(enabled, brightness, contrast, saturation):
	image_adjust.visible = enabled
	image_adjust.material.set_shader_param("brightness", brightness)
	image_adjust.material.set_shader_param("contrast", contrast)
	image_adjust.material.set_shader_param("saturation", saturation)

func _unhandled_input(event):
	if not get_tree().paused and event.is_action_pressed("ui_tablet_toggle") and not game_state.is_video_cutscene():
		get_tree().set_input_as_handled()
		show_tablet(true, PLDTablet.ActivationMode.DESKTOP)
