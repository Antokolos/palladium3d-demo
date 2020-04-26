extends Control

onready var dimmer = get_node("Dimmer")
onready var tablet = get_node("tablet")

func is_menu_hud():
	return true

func is_tablet_visible():
	return tablet.visible

func pause_game(enable):
	dimmer.visible = enable
	get_tree().paused = enable

func show_tablet(is_show, activation_mode = Tablet.ActivationMode.DESKTOP):
	if is_show:
		pause_game(true)
		tablet.visible = true
		tablet.activate(activation_mode)
	else:
		tablet.visible = false
		pause_game(false)
		settings.save_settings()

func _unhandled_input(event):
	if not get_tree().paused and event.is_action_pressed("ui_tablet_toggle"):
		get_tree().set_input_as_handled()
		show_tablet(true, Tablet.ActivationMode.DESKTOP)
