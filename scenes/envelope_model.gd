extends Spatial

func get_custom_actions():
	return [{"action_event" : "item_preview_action_1", "action_hint" : "Открыть конверт"}]

func execute_action(event, item):
	if event.is_action_pressed("item_preview_action_1"):
		item.remove()
		game_params.take("barn_lock_key")
	elif event.is_action_pressed("item_preview_action_2"):
		pass
	elif event.is_action_pressed("item_preview_action_3"):
		pass
	elif event.is_action_pressed("item_preview_action_4"):
		pass
	else:
		return false
	return true