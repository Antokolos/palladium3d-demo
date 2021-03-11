extends PLDUsable

const PANORAMA_EVENING = preload("res://addons/palladium/assets/spherical_hdr.hdr")
const SKY_ROTATION_EVENING = Vector3(0.0, 0.0, 0.0)

func use(player_node, camera_node):
	if game_state.has_item(DB.TakableIds.ATHENA) \
		and not game_state.is_in_party(CHARS.FEMALE_NAME_HINT) \
		and not game_state.is_in_party(CHARS.BANDIT_NAME_HINT):
		PREFS.set_achievement("SELF_CONFIDENCE")
		game_state.change_scene("res://ending_2.tscn", false, true)
	else:
		if game_state.has_item(DB.TakableIds.ATHENA) \
			or game_state.has_item(DB.TakableIds.PALLADIUM) \
			or game_state.get_activatable_state_by_id(DB.ActivatableIds.LAST_TRAP_FLOOR) == PLDGameState.ActivatableState.ACTIVATED:
			game_state.change_sky_panorama(false, PANORAMA_EVENING, SKY_ROTATION_EVENING, PLDGameState.TimeOfDay.EVENING)
		game_state.change_scene("res://forest.tscn", true)

func add_highlight(player_node):
	return common_utils.get_action_input_control() + tr("ACTION_GO_OUTSIDE")
