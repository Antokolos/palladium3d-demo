extends PLDUsable

func use(player_node, camera_node):
	game_params.change_scene("res://forest.tscn")

func add_highlight(player_node):
	return "E: " + tr("ACTION_GO_OUTSIDE")
