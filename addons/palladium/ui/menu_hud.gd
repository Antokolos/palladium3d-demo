extends Control

onready var dimmer = get_node("Dimmer")
onready var tablet = get_node("tablet")

func _ready():
	common_utils.show_mouse_cursor_if_needed_in_game(self)
	$LabelJoyHint.visible = common_utils.has_joypads()
	Input.connect("joy_connection_changed", self, "_on_joy_connection_changed")

func _on_joy_connection_changed(device_id, is_connected):
	$LabelJoyHint.visible = common_utils.has_joypads()

func is_menu_hud():
	return true

func is_tablet_visible():
	return tablet.visible

func is_quit_dialog_visible():
	return get_node("quit_dialog").visible

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

func _unhandled_input(event):
	if not get_tree().paused and event.is_action_pressed("ui_tablet_toggle") and not game_state.is_video_cutscene():
		get_tree().set_input_as_handled()
		show_tablet(true, PLDTablet.ActivationMode.DESKTOP)
