extends Area
class_name PLDPatrolArea

export(NodePath) var agent_path = null

onready var agent : PLDCharacter = get_node(agent_path) if agent_path and has_node(agent_path) else null

var waypoints = []
var waypoint_idx = 0

func _ready():
	if agent:
		agent.connect("patrolling_changed", self, "_on_patrolling_changed")
		agent.connect("arrived_to", self, "_on_arrived_to")
	connect("body_entered", self, "_on_patrol_area_body_entered")
	#connect("body_exited", self, "_on_patrol_area_body_exited")
	for ch in get_children():
		if ch is Position3D:
			waypoints.append(ch)

func _on_patrolling_changed(player_node, previous_state, new_state):
	if new_state:
		do_patrol()
	else:
		agent.set_target_node(null)

func _on_arrived_to(player_node, target_node):
	var next_target = get_next_target()
	agent.set_target_node(next_target if next_target else target_node, false)

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

func get_closest_waypoint(node_to):
	if not node_to:
		push_warning("Error calling get_closest_waypoint() for patrol area: no node specified")
		return { "waypoint" : null, "waypoint_idx" : -1 }
	if waypoints.empty():
		push_warning("Error calling get_closest_waypoint() for patrol area: no waypoints specified")
		return { "waypoint" : null, "waypoint_idx" : -1 }
	var result = waypoints[0]
	var result_idx = 0
	var origin = node_to.get_global_transform().origin
	var min_distance = origin.distance_squared_to(result.get_global_transform().origin)
	var idx = 0
	for wp in waypoints:
		if origin.distance_squared_to(wp.get_global_transform().origin) < min_distance:
			result = wp
			result_idx = idx
		idx = idx + 1
	return { "waypoint" : result, "waypoint_idx" : result_idx }

func do_patrol():
	if not agent:
		push_warning("Error calling do_patrol() for patrol area: agent path is incorrect")
		return
	var wp_data = get_closest_waypoint(agent)
	if not wp_data.waypoint:
		return
	waypoint_idx = wp_data.waypoint_idx
	agent.set_target_node(wp_data.waypoint, false)

func _on_patrol_area_body_entered(body):
	if body.is_in_group("party") and body.is_player():
		if not agent:
			push_warning("Error calling _on_patrol_area_body_entered() for patrol area: agent path is incorrect")
			return
		agent.activate()

#func _on_patrol_area_body_exited(body):
#	if not agent:
#		push_warning("Error calling _on_patrol_area_body_exited() for patrol area: agent path is incorrect")
#		return
#	if body.is_in_group("party") and body.is_player() and not agent.is_aggressive():
#		agent.set_target_node(null)
#		agent.deactivate()
