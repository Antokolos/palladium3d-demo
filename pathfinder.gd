extends KinematicBody
class_name PLDPathfinder

signal arrived_to(player_node, target_node)
signal arrived_to_boundary(player_node, target_node)

const Z_DIR = Vector3(0, 0, 1)

const DRAW_PATH = false

const MOUSE_SENSITIVITY = 0.1 #0.05
const KEY_LOOK_SPEED_FACTOR = 30

const FOLLOW_RANGE = 3
const CLOSEUP_RANGE = 2
const ALIGNMENT_RANGE = 0.2

onready var pyramid = get_parent()

var rest_state = true
var pathfinding_enabled = true
var target_node = null
var path = []
var angle_rad_y = 0

func is_rest_state():
	return rest_state

func has_collisions():
	var sc = get_slide_count()
	for i in range(0, sc):
		var collision = get_slide_collision(i)
		if not collision.collider.get_collision_mask_bit(2):
			return true
	return false

func get_target_node():
	return target_node

func set_target_node(node):
	target_node = node

func get_preferred_target():
	return target_node if not is_in_party() else (game_params.get_companion() if is_player() else game_params.get_player())

func get_target_position():
	var t = get_preferred_target()
	return t.get_global_transform().origin if t else null

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
	
	var rotation_angle = 0
	var rotation_angle_to_target_deg = 0
	var preferred_target = get_preferred_target()
	if preferred_target:
		var t = preferred_target.get_global_transform()
		var target_position = t.origin
		var mov_vec = target_position - current_position if was_moving else node_to_follow_pos - current_position
		mov_vec.y = 0
		rotation_angle = get_rotation_angle(cur_dir, next_dir) \
							if in_party or next_dir.length() > ALIGNMENT_RANGE \
							else get_rotation_angle(cur_dir, t.basis.xform(Z_DIR))
		rotation_angle_to_target_deg = rad2deg(get_rotation_angle(cur_dir, mov_vec))
	
	return {
		"next_dir" : next_dir,
		"rotation_angle" : rotation_angle,
		"rotation_angle_to_target_deg" : rotation_angle_to_target_deg
	}

func follow(in_party, current_transform, next_position):
	var was_moving = not rest_state
	var p = get_follow_parameters(in_party, game_params.get_player().get_global_transform().origin, current_transform, next_position)
	var next_dir = p.next_dir
	var distance = next_dir.length()
	var rotation_angle = p.rotation_angle
	var rotation_angle_to_target_deg = p.rotation_angle_to_target_deg
	
	angle_rad_y = 0
	if not in_party or not is_rest_state():
		if rotation_angle > 0.1:
			angle_rad_y = deg2rad(KEY_LOOK_SPEED_FACTOR * MOUSE_SENSITIVITY)
		elif rotation_angle < -0.1:
			angle_rad_y = deg2rad(KEY_LOOK_SPEED_FACTOR * MOUSE_SENSITIVITY * -1)
	
	var dir = Vector3()
	if not path.empty():
		rest_state = false
		if distance <= ALIGNMENT_RANGE:
			path.pop_front()
		else:
			dir = next_dir.normalized()
		if not $SoundWalking.is_playing():
			$SoundWalking.play()
	elif in_party and distance > FOLLOW_RANGE:
		rest_state = false
		dir = next_dir.normalized()
		if not $SoundWalking.is_playing():
			$SoundWalking.play()
	elif (in_party and distance > CLOSEUP_RANGE and not is_rest_state()) or (not in_party and distance > ALIGNMENT_RANGE):
		if was_moving and not in_party and target_node and angle_rad_y == 0 and get_slide_count() > 0:
			var collision = get_slide_collision(0)
			if collision.collider_id == target_node.get_instance_id():
				rest_state = true
				emit_signal("arrived_to_boundary", self, target_node)
				return {
					"dir" : dir,
					"rest_state" : rest_state,
					"rotation_angle_to_target_deg" : rotation_angle_to_target_deg
				}
		rest_state = false
		dir = next_dir.normalized()
		if not $SoundWalking.is_playing():
			$SoundWalking.play()
	else:
		if in_party:
			rest_state = true
		else:
			if was_moving and target_node and angle_rad_y == 0 and distance <= ALIGNMENT_RANGE:
				rest_state = true
				emit_signal("arrived_to", self, target_node)
	return {
		"dir" : dir,
		"rest_state" : rest_state,
		"rotation_angle_to_target_deg" : rotation_angle_to_target_deg
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