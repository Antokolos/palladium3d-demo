extends StaticBody

func use(player_node):
	conversation_manager.start_area_conversation("010-1-2_MusesHint")

func add_highlight(player_node):
	return "E: " + tr("ACTION_READ")

func remove_highlight(player_node):
	pass