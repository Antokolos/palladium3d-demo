extends Control

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_RestartButton_pressed():
	return get_tree().change_scene("res://palladium.tscn")
