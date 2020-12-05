extends Spatial

onready var ray_items = $RayCastItems
onready var ray_characters = $RayCastCharacters
var action_body = null
var use_distance = 0

func rebuild_exceptions(player_node):
	ray_items.clear_exceptions()
	ray_items.add_exception(player_node)
	ray_characters.clear_exceptions()
	ray_characters.add_exception(player_node)

func enable(enable):
	ray_items.enabled = enable
	ray_characters.enabled = enable

func body_is_usable(body, distance_to_body):
	return body \
		and (body is PLDUsable or body is PLDPathfinder) \
		and distance_to_body <= body.get_use_distance()

func ray_action(ray, player_node, camera_node):
	if not ray.enabled:
		return false
	ray.force_raycast_update()
	if ray.is_colliding():
		var collision_vec = ray.to_local(ray.get_collision_point())
		var body = ray.get_collider()
		if player_node.equals(body):
			pass
		elif body_is_usable(body, collision_vec.length()):
			body.use(player_node, camera_node)
			return true
	return false

func action(player_node, camera_node):
	if game_state.get_hud().is_in_conversation():
		return
	if ray_action(ray_items, player_node, camera_node) \
		or ray_action(ray_characters, player_node, camera_node):
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
	DB.execute_custom_action(event, item)

func switch_highlight(player_node, body, distance_to_body):
	if action_body:
		var ref = action_body.get_ref()
		if body_is_usable(ref, 0):
			ref.remove_highlight(player_node)
	action_body = weakref(body) if body else null
	var hint_message = body.add_highlight(player_node) if body_is_usable(body, distance_to_body) else null
	if hint_message:
		return hint_message
	else:
		var item = game_state.get_hud().get_active_item()
		if not item:
			return ""
		var custom_actions = game_state.get_custom_actions(item)
		if custom_actions.empty():
			return ""
		return common_utils.get_action_key("action") + tr(DB.get_item_name(item.item_id) + "_" + custom_actions[0])

func highlight(player_node):
	if game_state.get_hud().is_in_conversation():
		return ""
	if player_node.is_hidden():
		return "E: " + tr("ACTION_UNHIDE")
	var text_ray_items = ray_highlight(ray_items, player_node)
	return ray_highlight(ray_characters, player_node) if text_ray_items.empty() else text_ray_items

func ray_highlight(ray, player_node):
	# ray.force_raycast_update() -- do not using this, because we'll call this during _physics_process
	var body = null
	if ray.is_colliding():
		var collision_vec = ray.to_local(ray.get_collision_point())
		body = ray.get_collider()
		use_distance = 0 if player_node.equals(body) else collision_vec.length()
	else:
		use_distance = 0
	return switch_highlight(player_node, body, use_distance)

func get_use_distance():
	return use_distance