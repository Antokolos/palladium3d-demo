extends PLDUsable

func get_brick_node():
	return get_parent().get_node("golden_brick")

func brick_not_taken():
	return get_brick_node().visible

func use(player_node, camera_node):
	var zeus_body = game_state.get_usable(DB.UsableIds.ZEUS_POSTAMENT)
	if brick_not_taken():
		game_state.take(DB.TakableIds.GOLDEN_BAR)
		get_brick_node().visible = false
	elif game_state.has_item(DB.TakableIds.GOLDEN_BAR) \
		and not zeus_body.cell_phone_applied():
		game_state.remove(DB.TakableIds.GOLDEN_BAR)
		get_brick_node().visible = true
		$AudioStreamPlayer3D.play()
	else:
		return
	.use(player_node, camera_node)

func add_highlight(player_node):
	var zeus_body = game_state.get_usable(DB.UsableIds.ZEUS_POSTAMENT)
	return (
		("E: " + tr("ACTION_TAKE")
			if brick_not_taken()
			else ("" if zeus_body.cell_phone_applied() else "E: " + tr("ACTION_PUT_GB")))
	)

func restore_state():
	if game_state.has_item(DB.TakableIds.GOLDEN_BAR):
		get_brick_node().visible = false
		.use(game_state.get_player(), null)