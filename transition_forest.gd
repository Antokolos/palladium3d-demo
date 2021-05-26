extends PLDUsable

func use(player_node, camera_node):
	if game_state.has_item(DB.TakableIds.ATHENA) \
		and not game_state.is_in_party(CHARS.FEMALE_NAME_HINT) \
		and not game_state.is_in_party(CHARS.BANDIT_NAME_HINT):
		PREFS.set_achievement("SELF_CONFIDENCE")
		game_state.change_scene("res://ending_2.tscn", false, true)
	else:
		game_state.change_scene("res://forest.tscn", true)

func get_usage_code(player_node):
	return "ACTION_GO_OUTSIDE"
