extends PLDLootable

func use(player_node, camera_node):
	if .use(player_node, camera_node):
		visible = false