extends PLDUsable

func use(player_node, camera_node):
	for character in game_state.get_characters():
		if character.is_in_party():
			# Because it was disabled in the tunnel area and needs to be enabled in labyrinth
			character.set_pathfinding_enabled(true)
	game_state.change_scene("res://palladium.tscn", true)

func get_usage_code(player_node):
	return "ACTION_GO_INSIDE"
