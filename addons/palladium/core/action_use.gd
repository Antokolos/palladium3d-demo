extends Spatial

onready var ray = $Ray_Cast
var action_body = null

func rebuild_exceptions(player_node):
	ray.clear_exceptions()
	ray.add_exception(player_node)

func enable(enable):
	ray.enabled = enable

func body_is_usable(body):
	return body and (body is PLDUsable or body is PLDPathfinder)

func action(player_node, camera_node):
	if not ray.enabled:
		return
	
	ray.force_raycast_update()
	if ray.is_colliding():
		var body = ray.get_collider()
		if body.get_instance_id() == player_node.get_instance_id():
			pass
		elif body_is_usable(body):
			body.use(player_node, camera_node)
			return
	var item = game_state.get_hud().get_active_item()
	if not item:
		return
	var custom_actions = game_state.get_custom_actions(item)
	if custom_actions.empty():
		return
	var event = InputEventAction.new()
	event.set_action(custom_actions[0])
	event.set_pressed(true)
	game_state.execute_custom_action(event, item)

func switch_highlight(player_node, body):
	if action_body:
		var ref = action_body.get_ref()
		if body_is_usable(ref):
			ref.remove_highlight(player_node)
	action_body = weakref(body) if body else null
	var hint_message = body.add_highlight(player_node) if body_is_usable(body) else null
	if hint_message:
		return hint_message
	else:
		var item = game_state.get_hud().get_active_item()
		if not item:
			return ""
		var custom_actions = game_state.get_custom_actions(item)
		if custom_actions.empty():
			return ""
		return common_utils.get_action_key("action") + tr(item.nam + "_" + custom_actions[0])

func highlight(player_node):
	# ray.force_raycast_update() -- do not using this, because we'll call this during _physics_process
	if ray.is_colliding():
		var body = ray.get_collider()
		if body.get_instance_id() == player_node.get_instance_id():
			return switch_highlight(player_node, null)
		else:
			return switch_highlight(player_node, body)
	else:
		return switch_highlight(player_node, null)
