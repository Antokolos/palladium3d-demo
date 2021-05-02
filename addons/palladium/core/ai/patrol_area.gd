extends Area
class_name PLDPatrolArea

export(NodePath) var agent_path = null

onready var agent : PLDCharacter = get_node(agent_path) if agent_path and has_node(agent_path) else null

var waypoints = []
var waypoint_idx = 0
var first_hit = true

func _ready():
	first_hit = true
	if agent:
		agent.connect("patrolling_changed", self, "_on_patrolling_changed")
		agent.connect("arrived_to", self, "_on_arrived_to")
		agent.connect("take_damage", self, "_on_take_damage")
	connect("body_entered", self, "_on_patrol_area_body_entered")
	connect("body_exited", self, "_on_patrol_area_body_exited")
	for ch in get_children():
		if ch is Position3D:
			waypoints.append(ch)

func _on_patrolling_changed(player_node, previous_state, new_state):
	if agent.get_morale() < 0:
		return
	if new_state:
		do_patrol()
	else:
		agent.set_target_node(null)

func _on_arrived_to(player_node, target_node):
	var p = target_node.get_parent()
	if not p:
		return
	if p.get_instance_id() != get_instance_id():
		# If target node is not a child of the current patrol area, do nothing
		return
	var next_target = get_next_target()
	agent.set_morale(0)
	agent.set_target_node(next_target if next_target else target_node, false)
	agent.set_sprinting(false)

func _on_take_damage(player_node, fatal, hit_direction_node, hit_dir_vec):
	var wp_data = {
		"farthest_wp" : waypoints[0],
		"farthest_wp_idx" : 0
	} if first_hit else get_waypoint_data(agent)
	first_hit = false
	if not wp_data.farthest_wp:
		return
	waypoint_idx = wp_data.farthest_wp_idx
	agent.set_morale(-1)
	agent.set_target_node(wp_data.farthest_wp)
	agent.set_sprinting(true)

func get_next_target():
	if waypoints.empty():
		return null
	var wp_size = waypoints.size()
	if waypoint_idx < wp_size - 1:
		waypoint_idx = waypoint_idx + 1
	elif wp_size > 1:
		waypoints.invert()
		waypoint_idx = 1
	else:
		return null
	return waypoints[waypoint_idx]

func get_waypoint_data(node_to):
	if not node_to:
		push_warning("Error calling get_waypoint_data() for patrol area: no node specified")
		return { "waypoint" : null, "waypoint_idx" : -1 }
	if waypoints.empty():
		push_warning("Error calling get_waypoint_data() for patrol area: no waypoints specified")
		return { "waypoint" : null, "waypoint_idx" : -1 }
	var closest_wp = waypoints[0]
	var closest_wp_idx = 0
	var farthest_wp = waypoints[0]
	var farthest_wp_idx = 0
	var origin = node_to.get_global_transform().origin
	var min_distance = origin.distance_squared_to(closest_wp.get_global_transform().origin)
	var max_distance = 0
	var idx = 0
	for wp in waypoints:
		var d = origin.distance_squared_to(wp.get_global_transform().origin)
		if d < min_distance:
			min_distance = d
			closest_wp = wp
			closest_wp_idx = idx
		if d > max_distance:
			max_distance = d
			farthest_wp = wp
			farthest_wp_idx = idx
		idx = idx + 1
	return {
		"closest_wp" : closest_wp,
		"closest_wp_idx" : closest_wp_idx,
		"farthest_wp" : farthest_wp,
		"farthest_wp_idx" : farthest_wp_idx
	}

func do_patrol():
	if not agent:
		push_warning("Error calling do_patrol() for patrol area: agent path is incorrect")
		return
	var wp_data = get_waypoint_data(agent)
	if not wp_data.closest_wp:
		return
	waypoint_idx = wp_data.closest_wp_idx
	agent.set_target_node(wp_data.closest_wp)
	agent.set_sprinting(false)

func _on_patrol_area_body_entered(body):
	if body.is_in_group("party") and body.is_player():
		if not agent:
			push_warning("Error calling _on_patrol_area_body_entered() for patrol area: agent path is incorrect")
			return
		if agent.get_relationship() < 0:
			agent.activate()
			do_patrol()

func _on_patrol_area_body_exited(body):
	if not agent:
		push_warning("Error calling _on_patrol_area_body_exited() for patrol area: agent path is incorrect")
		return
	if body.is_in_group("party") and body.is_player() and not body.is_hidden():
		if not agent.is_aggressive() \
			and agent.get_relationship() < 0:
			agent.set_target_node(null)
			agent.deactivate()
