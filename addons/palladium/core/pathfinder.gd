extends KinematicBody
class_name PLDPathfinder

signal arrived_to(player_node, target_node)
signal arrived_to_boundary(player_node, target_node)

const Z_DIR = Vector3(0, 0, 1)

const DRAW_PATH = false

const ROTATION_ANGLE_MIN_RAD = 0.1
const MOUSE_SENSITIVITY = 0.1 #0.05
const KEY_LOOK_SPEED_FACTOR = 30

const FOLLOW_RANGE = 3
const CLOSEUP_RANGE = 2
const ALIGNMENT_RANGE = 0.2

export var name_hint = DB.PLAYER_NAME_HINT

onready var pyramid = get_parent()

var rest_state = true
var pathfinding_enabled = true
var target_node = null
var path = []

var angle_rad_y = 0
var dir = Vector3()
var rotation_angle_to_target_deg = 0

### Use target ###
# It is very similar to the code in PLDUsable,
# but unfortunately we need the inheritance from KinematicBody

func use(player_node, camera_node):
	pass

func add_highlight(player_node):
	return ""

func remove_highlight(player_node):
	pass

func get_name_hint():
	return name_hint

func get_rotation_angle_to_target_deg():
	return rotation_angle_to_target_deg

func is_in_party():
	return game_state.is_in_party(name_hint)

func is_player():
	return game_state.get_player().get_instance_id() == self.get_instance_id()

func is_rest_state():
	return rest_state

func has_collisions():
	var sc = get_slide_count()
	for i in range(0, sc):
		var collision = get_slide_collision(i)
		if not collision.collider.get_collision_mask_bit(2):
			return true
	return false

func set_dir(dir):
	self.dir = dir

func reset_movement():
	set_dir(Vector3())

func reset_rotation():
	angle_rad_y = 0

func reset_movement_and_rotation():
	reset_movement()
	reset_rotation()

func get_target_node():
	return target_node

func set_target_node(node):
	target_node = node

func get_preferred_target():
	return target_node if not is_in_party() else (game_state.get_companion() if is_player() else game_state.get_player())

func get_target_position():
	var t = get_preferred_target()
	return t.get_global_transform().origin if t else null

func teleport(node_to):
	if node_to:
		clear_path()
		set_global_transform(node_to.get_global_transform())
		reset_movement_and_rotation()

func set_pathfinding_enabled(enabled):
	pathfinding_enabled = enabled

func get_rotation_angle(cur_dir, target_dir):
	var c = cur_dir.normalized()
	var t = target_dir.normalized()
	var cross = c.cross(t)
	var sgn = 1 if cross.y > 0 else -1
	var dot = c.dot(t)
	if dot > 1.0:
		return 0
	elif dot < -1.0:
		return PI
	else:
		return sgn * acos(dot)

func get_follow_parameters(in_party, node_to_follow_pos, current_transform, next_position):
	var was_moving = not rest_state
	var current_position = current_transform.origin
	var cur_dir = current_transform.basis.xform(Z_DIR)
	cur_dir.y = 0
	var next_dir = next_position - current_position
	next_dir.y = 0
	var distance = next_dir.length()
	
	var preferred_target = get_preferred_target()
	if preferred_target:
		var t = preferred_target.get_global_transform()
		var target_position = t.origin
		var mov_vec = target_position - current_position if was_moving else node_to_follow_pos - current_position
		mov_vec.y = 0
		var rotation_angle = get_rotation_angle(cur_dir, next_dir) \
								if in_party or distance > ALIGNMENT_RANGE \
								else get_rotation_angle(cur_dir, t.basis.xform(Z_DIR))
		return {
			"dir" : next_dir.normalized(),
			"distance" : distance,
			"rest_state" : rotation_angle > -ROTATION_ANGLE_MIN_RAD and rotation_angle < ROTATION_ANGLE_MIN_RAD,
			"rotation_angle" : rotation_angle,
			"rotation_angle_to_target_deg" : rad2deg(get_rotation_angle(cur_dir, mov_vec)),
			"sgnl" : null
		}
	else:
		return {
			"dir" : next_dir.normalized(),
			"distance" : distance,
			"rest_state" : true,
			"rotation_angle" : 0,
			"rotation_angle_to_target_deg" : 0,
			"sgnl" : null
		}

func follow(in_party, current_transform, next_position):
	var rest_state = is_rest_state()
	var was_moving = not rest_state
	var p = get_follow_parameters(in_party, game_state.get_player().get_global_transform().origin, current_transform, next_position)
	
	var next_dir = Vector3()
	if not path.empty():
		rest_state = false
		if p.distance <= ALIGNMENT_RANGE:
			path.pop_front()
		else:
			next_dir = p.dir
	elif in_party and p.distance > FOLLOW_RANGE:
		rest_state = false
		next_dir = p.dir
	elif (in_party and p.distance > CLOSEUP_RANGE and not is_rest_state()) \
		or (not in_party and p.distance > ALIGNMENT_RANGE):
		if was_moving and not in_party and target_node and angle_rad_y == 0 and get_slide_count() > 0:
			var collision = get_slide_collision(0)
			if collision.collider_id == target_node.get_instance_id():
				rest_state = true
				return {
					"dir" : next_dir,
					"rest_state" : rest_state,
					"rotation_angle" : p.rotation_angle,
					"rotation_angle_to_target_deg" : p.rotation_angle_to_target_deg,
					"sgnl" : "arrived_to_boundary"
				}
		rest_state = false
		next_dir = p.dir
	else:
		if in_party:
			rest_state = true
		else:
			if was_moving and target_node and angle_rad_y == 0 and p.distance <= ALIGNMENT_RANGE:
				rest_state = true
				return {
					"dir" : next_dir,
					"rest_state" : rest_state,
					"rotation_angle" : p.rotation_angle,
					"rotation_angle_to_target_deg" : p.rotation_angle_to_target_deg,
					"sgnl" : "arrived_to"
				}
	return {
		"dir" : next_dir,
		"rest_state" : rest_state,
		"rotation_angle" : p.rotation_angle,
		"rotation_angle_to_target_deg" : p.rotation_angle_to_target_deg,
		"sgnl" : null
	}

func update_navpath(pstart, pend):
	path = get_navpath(pstart, pend)
	if DRAW_PATH:
		draw_path()

func get_navpath(pstart, pend):
	if not pathfinding_enabled:
		return []
	var p1 = pyramid.get_closest_point(pstart)
	var p2 = pyramid.get_closest_point(pend)
	var p = pyramid.get_simple_path(p1, p2, true)
	return Array(p) # Vector3array too complex to use, convert to regular array

func build_path(target_position, in_party):
	var current_position = get_global_transform().origin
	var mov_vec = target_position - current_position
	mov_vec.y = 0
	if in_party:
		if mov_vec.length() < CLOSEUP_RANGE - ALIGNMENT_RANGE:
			clear_path()
			return
		# filter out points of the path, distance to which is greater than distance to player
		while not path.empty():
			var pt = path.back()
			var mov_pt = target_position - pt
			if mov_pt.length() <= mov_vec.length():
				break
			path.pop_back()
	if has_collisions() and path.empty(): # should check possible stuck
		#clear_path()
		update_navpath(current_position, target_position)

func draw_path():
	for ch in pyramid.get_node("path_holder").get_children():
		pyramid.get_node("path_holder").remove_child(ch)
	var k = 1.0
	for p in path:
		var m = MeshInstance.new()
		m.mesh = SphereMesh.new()
		m.mesh.radius = 0.1 * k
		k = k + 0.1
		pyramid.get_node("path_holder").add_child(m)
		m.global_translate(p)

func clear_path():
	for ch in pyramid.get_node("path_holder").get_children():
		pyramid.get_node("path_holder").remove_child(ch)
	path.clear()

func get_distance_to_target():
	var target_position = get_target_position()
	if target_position:
		var current_position = get_global_transform().origin
		var mov_vec = target_position - current_position
		mov_vec.y = 0
		return mov_vec.length()
	else:
		return 0.0

func shadow_casting_enable(enable):
	common_utils.shadow_casting_enable(self, enable)

func do_process(delta):
	dir = Vector3()
	var in_party = is_in_party()
	var is_player = is_player()
	var target_position = get_target_position()
	if target_position:
		var current_transform = get_global_transform()
		var data
		if not is_player or not in_party:
			var current_position = current_transform.origin
			build_path(target_position, in_party)
			data = follow(in_party, current_transform, path.front() if path.size() > 0 else target_position)
			dir = data.dir
		elif is_player and cutscene_manager.is_cutscene():
			data = get_follow_parameters(in_party, target_position, current_transform, target_position)
		else:
			return
		angle_rad_y = 0
		if not in_party or not is_rest_state():
			if data.rotation_angle > ROTATION_ANGLE_MIN_RAD:
				angle_rad_y = deg2rad(KEY_LOOK_SPEED_FACTOR * MOUSE_SENSITIVITY)
			elif data.rotation_angle < -ROTATION_ANGLE_MIN_RAD:
				angle_rad_y = deg2rad(KEY_LOOK_SPEED_FACTOR * MOUSE_SENSITIVITY * -1)
		rotation_angle_to_target_deg = data.rotation_angle_to_target_deg
		rest_state = data.rest_state
		if data.sgnl:
			emit_signal(data.sgnl, self, target_node)
