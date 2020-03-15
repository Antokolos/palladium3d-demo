extends Spatial

func get_custom_actions():
	return [{"key_code" : KEY_R, "action_hint" : "R -- открыть конверт"}]

func execute_action(key_code, item):
	match key_code:
		KEY_R:
			item.remove()
			game_params.take("barn_lock_key")