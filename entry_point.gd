extends Node

func _ready():
	game_params.scene_path = "res://main_menu.tscn"
	get_tree().change_scene("res://addons/palladium/ui/scene_loader.tscn")