extends PLDUsable

func get_brick_node():
	return get_parent().get_node("golden_brick")

func brick_not_taken():
	return get_brick_node().visible

func use(player_node, camera_node):
	if brick_not_taken():
		game_state.take(DB.TakableIds.GOLDEN_BAR)
		get_brick_node().visible = false
	elif game_state.has_item(DB.TakableIds.GOLDEN_BAR):
		game_state.remove(DB.TakableIds.GOLDEN_BAR)
		get_brick_node().visible = true
		$AudioStreamPlayer3D.play()
	.use(player_node, camera_node)

func add_highlight(player_node):
	return "E: " + (tr("ACTION_TAKE") if brick_not_taken() else tr("ACTION_PUT_GB"))