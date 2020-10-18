extends PLDUsable

func use(player_node, camera_node):
	if game_state.has_item(DB.TakableIds.ATHENA) \
		and not game_state.is_in_party(CHARS.FEMALE_NAME_HINT) \
		and not game_state.is_in_party(CHARS.BANDIT_NAME_HINT):
		game_state.change_scene("res://ending_2.tscn", false, true)
	else:
		game_state.change_scene("res://forest.tscn", true)

func add_highlight(player_node):
	return "E: " + tr("ACTION_GO_OUTSIDE")
