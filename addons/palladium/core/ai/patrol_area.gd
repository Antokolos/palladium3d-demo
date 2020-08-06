extends Area
class_name PLDPatrolArea

export(NodePath) var agent_path = null

onready var agent : PLDCharacter = get_node(agent_path) if agent_path and has_node(agent_path) else null

var waypoints = []

func _ready():
	if agent:
		agent.connect("patrolling_changed", self, "_on_patrolling_changed")
		agent.connect("arrived_to", self, "_on_arrived_to")
	connect("body_entered", self, "_on_patrol_area_body_entered")
	for ch in get_children():
		if ch is Position3D:
			waypoints.append(ch)

func _on_patrolling_changed(player_node, previous_state, new_state):
	if new_state:
		do_patrol()
	else:
		agent.set_target_node(null)

func _on_arrived_to(player_node, target_node):
	if waypoints.empty():
		return
	var arrival_target_found = false
	for wp in waypoints:
		if arrival_target_found:
			agent.set_target_node(wp)
			return
		if wp.get_instance_id() == target_node.get_instance_id():
			arrival_target_found = true
	var wp_size = waypoints.size()
	if wp_size > 1:
		waypoints.invert()
		agent.set_target_node(waypoints[1])

func get_closest_waypoint():
	if waypoints.empty():
		return null
	var result = waypoints[0]
	var origin = get_global_transform().origin
	var min_distance = origin.distance_squared_to(result.get_global_transform().origin)
	for wp in waypoints:
		if origin.distance_squared_to(wp.get_global_transform().origin) < min_distance:
			result = wp
	return result

func do_patrol():
	if not agent:
		push_warning("Error calling do_patrol() for patrol area: agent path is incorrect")
		return
	if waypoints.empty():
		push_warning("Error calling do_patrol() for patrol area: no waypoints specified")
		return
	agent.set_target_node(get_closest_waypoint())

func _on_patrol_area_body_entered(body):
	if body.is_in_group("party") and body.is_player():
		if not agent:
			push_warning("Error calling _on_patrol_area_body_entered() for patrol area: agent path is incorrect")
			return
		agent.activate()
