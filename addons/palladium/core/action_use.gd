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

func body_is_highlightable(body, distance_to_body):
	return (
		body
		and (body is PLDUsable or body is PLDPathfinder)
		and distance_to_body <= body.get_use_distance()
	)

func body_is_usable(player_node, body, distance_to_body):
	return (
		body_is_highlightable(body, distance_to_body)
		and body.can_be_used_by(player_node)
	)

func ray_action(ray, player_node, camera_node):
	if not ray.enabled:
		return false
	ray.force_raycast_update()
	if ray.is_colliding():
		var collision_vec = ray.to_local(ray.get_collision_point())
		var body = ray.get_collider()
		if player_node.equals(body):
			pass
		elif body_is_usable(player_node, body, collision_vec.length()):
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
	if not item or item.is_weapon():
		return
	var custom_actions = game_state.get_custom_actions(item)
	if custom_actions.empty() or not DB.can_execute_custom_action(item, custom_actions[0]):
		return
	DB.execute_custom_action(item, custom_actions[0])

func switch_highlight(player_node, body, distance_to_body):
	if action_body:
		var ref = action_body.get_ref()
		if body_is_highlightable(ref, 0):
			ref.remove_highlight(player_node)
	action_body = weakref(body) if body else null
	var hint_message = body.add_highlight(player_node) if body_is_highlightable(body, distance_to_body) else null
	return {
		"hint_message" : hint_message if hint_message and not hint_message.empty() else null,
		"use_distance" : distance_to_body
	}

func highlight_custom_action():
	var item = game_state.get_hud().get_active_item()
	if not item or item.is_weapon():
		return ""
	var custom_actions = game_state.get_custom_actions(item)
	if custom_actions.empty() or not DB.can_execute_custom_action(item, custom_actions[0]):
		return ""
	return common_utils.get_action_input_control() + tr(DB.get_item_name(item.item_id) + "_" + custom_actions[0])

func highlight(player_node):
	if game_state.get_hud().is_in_conversation():
		return ""
	if player_node.is_hidden():
		if player_node.is_too_late_to_unhide():
			return ""
		return common_utils.get_action_input_control() + tr("ACTION_UNHIDE") + " | " + tr("MESSAGE_CONTROLS_FLASHLIGHT") % common_utils.get_input_control("flashlight", false)
	var data_items = ray_highlight(ray_items, player_node)
	use_distance = data_items.use_distance
	if data_items.hint_message:
		return data_items.hint_message
	var data_chars = ray_highlight(ray_characters, player_node)
	if use_distance == 0 \
		or (
			data_chars.use_distance > 0
			and data_chars.use_distance < use_distance
		):
		use_distance = data_chars.use_distance
	if data_chars.hint_message:
		return data_chars.hint_message
	return highlight_custom_action()

func ray_highlight(ray, player_node):
	# ray.force_raycast_update() -- do not using this, because we'll call this during _physics_process
	var body = null
	var d = 0
	if ray.is_colliding():
		var collision_vec = ray.to_local(ray.get_collision_point())
		body = ray.get_collider()
		d = 0 if player_node.equals(body) else collision_vec.length()
	return switch_highlight(player_node, body, d)

func get_use_distance():
	return use_distance