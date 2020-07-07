extends PLDUsable

func use(player_node, camera_node):
	game_params.scene_path = "res://palladium.tscn"
	get_tree().change_scene("res://scene_loader.tscn")

func add_highlight(player_node):
	return "E: " + tr("ACTION_GO_INSIDE")
