extends WindowDialog

onready var no_button = get_node("VBoxContainer/HBoxContainer/NoButton")

func _ready():
	get_tree().set_auto_accept_quit(false)
	get_close_button().connect("pressed", self, "_on_NoButton_pressed")

func _notification(what):
	match what:
		MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
			# TODO: check it is OK
			#if game_state.get_hud().is_tablet_visible():
			#	common_utils.toggle_pause_menu()
			popup_centered_ratio(0.3)
		NOTIFICATION_POST_POPUP:
			common_utils.show_mouse_cursor_if_needed(true)
			no_button.grab_focus()

func _input(event):
	if not visible:
		return
	if event.is_action_pressed("ui_tablet_toggle") or event.is_action_pressed("ui_cancel"):
		get_tree().set_input_as_handled()
		_on_NoButton_pressed()

func _on_YesButton_pressed():
	get_tree().quit()

func _on_NoButton_pressed():
	visible = false
	var hud = game_state.get_hud()
	if not hud.is_tablet_visible():
		common_utils.show_mouse_cursor_if_needed_in_game(hud)
		hud.pause_game(false)

func _on_quit_dialog_about_to_show():
	game_state.get_hud().pause_game(true)
