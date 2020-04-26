extends Control

onready var dimmer = get_node("Dimmer")
onready var tablet = get_node("tablet")

func _ready():
	var dialog = $QuitDialog
	dialog.get_ok().text = "Yes"
	dialog.get_cancel().text = "No"
	get_tree().set_auto_accept_quit(false)

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		ask_quit()

func is_menu_hud():
	return true

func ask_quit():
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	dimmer.visible = true
	$QuitDialog.popup_centered()

func show_tablet(is_show, activation_mode = Tablet.ActivationMode.DESKTOP):
	if is_show:
		dimmer.visible = true
		tablet.visible = true
		get_tree().paused = true
		tablet.activate(activation_mode)
	else:
		get_tree().paused = false
		tablet.visible = false
		dimmer.visible = false
		settings.save_settings()

func _unhandled_input(event):
	if not get_tree().paused and event.is_action_pressed("ui_tablet_toggle"):
		get_tree().set_input_as_handled()
		show_tablet(true, Tablet.ActivationMode.DESKTOP)

func _on_QuitDialog_confirmed():
	get_tree().quit()

func _on_QuitDialog_popup_hide():
	if not tablet.visible:
		get_tree().paused = false
		dimmer.visible = false

func _on_QuitDialog_about_to_show():
	get_tree().paused = true
