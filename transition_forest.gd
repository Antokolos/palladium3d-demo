extends PLDUsable

func use(player_node, camera_node):
	game_params.scene_path = "res://forest.tscn"
	get_tree().change_scene("res://addons/palladium/ui/scene_loader.tscn")

func add_highlight(player_node):
	return "E: " + tr("ACTION_GO_OUTSIDE")
