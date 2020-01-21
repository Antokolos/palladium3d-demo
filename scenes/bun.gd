extends Spatial

func get_custom_actions():
	return [{"key_code" : KEY_R, "action_hint" : "R -- съесть"}]

func execute_action(key_code, item):
	match key_code:
		KEY_R:
			item.remove()
			var player = game_params.get_player()
			conversation_manager.start_conversation(player, game_params.get_companion(), "BunEaten")