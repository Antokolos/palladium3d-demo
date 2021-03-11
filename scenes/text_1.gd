extends PLDUsable

func use(player_node, camera_node):
	conversation_manager.start_area_conversation("010-1-2_MusesHint")

func add_highlight(player_node):
	return "" if conversation_manager.conversation_is_in_progress() or conversation_manager.conversation_is_finished("010-1-2_MusesHint") else common_utils.get_action_input_control() + tr("ACTION_READ")
