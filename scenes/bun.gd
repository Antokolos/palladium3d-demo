extends Spatial

func get_custom_actions():
	return [{"key_code" : KEY_R, "action_hint" : "R -- съесть"}]

func execute_action(key_code, item):
	match key_code:
		KEY_R:
			item.remove()
			var player = get_node(game_params.player_path)
			conversation_manager.start_conversation(player, player, "BunEaten")