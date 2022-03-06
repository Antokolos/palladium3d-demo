extends WindowDialog

func _ready():
	get_close_button().connect("pressed", self, "_on_DifficultyNormalButton_pressed")
	get_node("VBoxContainer/HBoxContainer/DifficultyNormalButton").grab_focus()

func _input(event):
	if not visible:
		return
	if event.is_action_pressed("ui_tablet_toggle") or event.is_action_pressed("ui_cancel"):
		get_tree().set_input_as_handled()
		_on_DifficultyNormalButton_pressed()

func _on_DifficultyHardButton_pressed():
	visible = false
	settings.set_difficulty(PLDSettings.DIFFICULTY_HARD)
	game_state.get_hud().pause_game(false)
	game_state.change_scene("res://intro_full.tscn")

func _on_DifficultyNormalButton_pressed():
	visible = false
	settings.set_difficulty(PLDSettings.DIFFICULTY_NORMAL)
	game_state.get_hud().pause_game(false)
	game_state.change_scene("res://intro_full.tscn")

func _on_difficulty_dialog_about_to_show():
	game_state.get_hud().pause_game(true)
