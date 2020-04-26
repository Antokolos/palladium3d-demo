extends WindowDialog

onready var yes_button = get_node("VBoxContainer/HBoxContainer/YesButton")

func _ready():
	get_tree().set_auto_accept_quit(false)
	get_close_button().connect("pressed", self, "_on_NoButton_pressed")

func _notification(what):
	match what:
		MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
			if game_params.get_hud().is_tablet_visible():
				var ev = InputEventAction.new()
				ev.set_action("ui_tablet_toggle")
				ev.set_pressed(true)
				get_tree().input_event(ev)
			popup_centered()
		NOTIFICATION_POST_POPUP:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			yes_button.grab_focus()
			yes_button.grab_click_focus()

func _input(event):
	if visible and event.is_action_pressed("ui_cancel"):
		_on_NoButton_pressed()

func _on_YesButton_pressed():
	get_tree().quit()

func _on_NoButton_pressed():
	visible = false
	var hud = game_params.get_hud()
	if not hud.is_tablet_visible():
		if not hud.is_menu_hud():
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		hud.pause_game(false)

func _on_quit_dialog_about_to_show():
	game_params.get_hud().pause_game(true)
