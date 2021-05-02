extends PLDUseTarget
class_name BarnLock

const STATE_OPENED = 1

func use(player_node, camera_node):
	var uc = get_usage_code(player_node)
	if uc == "ACTION_EXAMINE":
		game_state.get_hud().queue_popup_message(
			"MESSAGE_KEY_USAGE_NEEDED"
				if game_state.has_item(DB.TakableIds.BARN_LOCK_KEY)
				else "MESSAGE_KEY_NEEDED"
		)
	else:
		.use(player_node, camera_node)

func use_action(player_node, item):
	game_state.set_multistate_state(get_path(), STATE_OPENED)
	$AudioStreamPlayer.play()
	visible = false
	return true

func get_usage_code(player_node):
	var uc = .get_usage_code(player_node)
	if uc and not uc.empty():
		return uc
	if visible:
		return "ACTION_EXAMINE"

func get_use_action_code(player_node, item):
	return "ACTION_OPEN"

func restore_state():
	var state = game_state.get_multistate_state(get_path())
	if state == STATE_OPENED:
		visible = false
