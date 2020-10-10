extends PLDTakable

func use(player_node, camera_node):
	var is_present = is_present()
	if is_present:
		var ad0 = game_state.get_door("palladium_rooms/Artemis_room/door_0")
		var ad1 = game_state.get_door("palladium_rooms/Artemis_room/door_1")
		if ad0 and ad0.is_opened() and ad1 and ad1.is_opened():
			conversation_manager.start_area_conversation_with_companion({
				CHARS.FEMALE_NAME_HINT : "StuckFemale",
				CHARS.BANDIT_NAME_HINT : "StuckBandit"
			}, true)
			return false
	return .use(player_node, camera_node)