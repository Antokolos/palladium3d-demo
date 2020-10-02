tool
extends PLDConversationArea

func is_conversation_enabled(name_hint, conversation_idx):
	return game_state.has_item(DB.TakableIds.ATHENA)

func do_when_conversation_finished(name_hint, conversation_name):
	var player = game_state.get_player()
	player.join_party()
	match name_hint:
		CHARS.BANDIT_NAME_HINT:
			var companion = game_state.get_character(CHARS.BANDIT_NAME_HINT)
			companion.join_party()
		CHARS.FEMALE_NAME_HINT:
			var companion = game_state.get_character(CHARS.FEMALE_NAME_HINT)
			companion.set_force_physics(true)
			companion.invoke_physics_pass()

func do_when_camera_restored(player_node, cutscene_node, name_hint, conversation_name):
	if name_hint == CHARS.FEMALE_NAME_HINT:
		game_state.get_usable(DB.UsableIds.LAST_TRAP_FLOOR).activate()

func _on_conversation_area_body_entered(body):
	if Engine.editor_hint:
		return false
	var player = game_state.get_player()
	if not player.equals(body):
		return false
	if not ._on_conversation_area_body_entered(body):
		return false
	player.clear_target_node()
	player.leave_party()
	player.teleport($PositionPlayer)
	var companion = game_state.get_companion()
	companion.clear_target_node()
	companion.leave_party()
	companion.teleport($PositionCompanion)