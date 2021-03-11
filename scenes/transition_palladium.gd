extends PLDUsable

func use(player_node, camera_node):
	for character in game_state.get_characters():
		if character.is_in_party():
			# Because it was disabled in the tunnel area and needs to be enabled in labyrinth
			character.set_pathfinding_enabled(true)
	game_state.change_scene("res://palladium.tscn", true)

func add_highlight(player_node):
	return common_utils.get_action_input_control() + tr("ACTION_GO_INSIDE")
