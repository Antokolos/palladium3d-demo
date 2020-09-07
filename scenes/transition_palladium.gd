extends PLDUsable

func use(player_node, camera_node):
	game_state.change_scene("res://palladium.tscn", true)

func add_highlight(player_node):
	return "E: " + tr("ACTION_GO_INSIDE")
