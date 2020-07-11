extends Control

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_TryAgainButton_pressed():
	game_params.autosave_restore()
