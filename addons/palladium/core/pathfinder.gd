extends KinematicBody
class_name PLDPathfinder

signal activated_changed(player_node, previous_state, new_state)
signal rest_state_changed(player_node, previous_state, new_state)
signal arrived_to(player_node, target_node)
signal arrived_to_boundary(player_node, target_node)

const Z_DIR = Vector3(0, 0, 1)

const DRAW_PATH = false

const ROTATION_ANGLE_MIN_RAD = 0.1
const KEY_LOOK_SPEED_FACTOR = 30

const MAX_RANGE = 10
const FOLLOW_RANGE = 3
const CLOSEUP_RANGE = 2
const POINT_BLANK_RANGE = 1.2
const ALIGNMENT_RANGE = 0.2
const USE_DISTANCE_COMMON = 2

export(int) var use_distance = USE_DISTANCE_COMMON
export var name_hint = CHARS.PLAYER_NAME_HINT
export(NodePath) var navigation_path = NodePath("..")

onready var navigation_node = get_node(navigation_path) if navigation_path and has_node(navigation_path) else null

var activated = false
var in_party = false
var rest_state = true
var pathfinding_enabled = true
var target_node = null
var point_of_interest = null
var path = []

var angle_rad_y = 0

### Use target ###
# It is very similar to the code in PLDUsable,
# but unfortunately we need the inheritance from KinematicBody

func get_use_distance():
	return use_distance

func use(player_node, camera_node):
	return false

func add_highlight(player_node):
	return ""

func remove_highlight(player_node):
	pass

func get_name_hint():
	return name_hint

func is_in_party():
	return in_party

func set_in_party(in_party):
	self.in_party = in_party

func join_party():
	activate()
	clear_path()
	set_in_party(true)
	reset_movement_and_rotation()

func leave_party():
	clear_path()
	set_in_party(false)
	reset_movement_and_rotation()
	update_navpath_to_target()

func equals(obj):
	return obj and (obj.get_instance_id() == self.get_instance_id())

func is_player():
	return equals(game_state.get_player())

func is_player_controlled():
	return is_in_party() and is_player() and not cutscene_manager.is_cutscene()

func is_activated():
	# Checking is_physics_processing() because node can be paused
	return activated and is_physics_processing()

func is_rest_state():
	return rest_state

func activate():
	var activated_prev = activated
	var rest_state_prev = rest_state
	activated = true
	rest_state = false
	reset_movement_and_rotation()
	if activated_prev != activated:
		emit_signal("activated_changed", self, activated_prev, activated)
	if rest_state_prev != rest_state:
		emit_signal("rest_state_changed", self, rest_state_prev, rest_state)

func deactivate():
	var activated_prev = activated
	var rest_state_prev = rest_state
	activated = false
	rest_state = true
	if activated_prev != activated:
		emit_signal("activated_changed", self, activated_prev, activated)
	if rest_state_prev != rest_state:
		emit_signal("rest_state_changed", self, rest_state_prev, rest_state)

func has_collisions():
	var sc = get_slide_count()
	for i in range(0, sc):
		var collision = get_slide_collision(i)
		if not collision.collider.get_collision_mask_bit(2):
			return true
	return false

func reset_movement():
	rest_state = true

func reset_rotation():
	angle_rad_y = 0

func reset_movement_and_rotation():
	reset_movement()
	reset_rotation()

func get_target_node():
	return target_node

func set_target_node(node, update_navpath = true):
	target_node = node
	if update_navpath:
		update_navpath_to_target()

func update_navpath_to_target():
	if target_node:
		var current_position = get_global_transform().origin
		var target_position = target_node.get_global_transform().origin
		update_navpath(current_position, target_position)

func clear_target_node():
	return set_target_node(null)

func get_point_of_interest():
	return point_of_interest

func set_point_of_interest(point_of_interest):
	self.point_of_interest = point_of_interest

func clear_poi_if_it_is(node):
	if not node:
		return false
	var poi = get_point_of_interest()
	if poi and poi.get_instance_id() == node.get_instance_id():
		clear_point_of_interest()
		return true
	return false

func clear_point_of_interest():
	set_point_of_interest(null)

func get_preferred_target():
	return target_node if not in_party else (game_state.get_companion() if is_player() else game_state.get_player())

func get_target_position():
	var t = get_preferred_target()
	return t.get_global_transform().origin if t else null

func teleport(node_to):
	if node_to:
		clear_path()
		set_global_transform(node_to.get_global_transform())
		reset_movement_and_rotation()

func is_pathfinding_enabled():
	return pathfinding_enabled

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

func is_zero_rotation(rotation_angle):
	return rotation_angle > -ROTATION_ANGLE_MIN_RAD and rotation_angle < ROTATION_ANGLE_MIN_RAD

func get_follow_parameters(target, current_transform, next_position) -> PLDMovementData:
	var was_moving = not is_rest_state()
	var current_position = current_transform.origin
	var cur_dir = current_transform.basis.xform(Z_DIR)
	var next_dir = next_position - current_position
	var horz_dir = next_dir
	horz_dir.y = 0
	var data : PLDMovementData = PLDMovementData.new()
	var d = next_dir.length()
	var need_moving = d > ALIGNMENT_RANGE and horz_dir.length() > ALIGNMENT_RANGE
	if need_moving:
		data.with_distance(d).with_dir(next_dir)
	cur_dir.y = 0
	next_dir.y = 0
	
	if target:
		var t = target.get_global_transform()
		var target_position = t.origin
		var target_dir = t.basis.xform(Z_DIR)
		target_dir.y = 0
		var mov_vec = target_position - current_position
		mov_vec.y = 0
		var ratt = (
			get_rotation_angle(cur_dir, mov_vec)
				if mov_vec.length() > ALIGNMENT_RANGE
				else get_rotation_angle(cur_dir, target_dir)
		)
		var ra = (
			get_rotation_angle(cur_dir, next_dir)
				if not point_of_interest and (in_party or need_moving)
				else ratt
		)
		return data \
			.with_rest_state(not need_moving and is_zero_rotation(ra)) \
			.with_rotation_angle(ra) \
			.with_rotation_angle_to_target_deg(rad2deg(ratt))
	else:
		return data.with_rest_state(true)

func is_arrived_to_boundary(tgt):
	var sc = get_slide_count()
	if sc <= 0:
		return false
	for i in range(sc):
		if get_slide_collision(i).collider_id == tgt.get_instance_id():
			return true
	return false

func follow(current_transform, next_position):
	var was_moving = not is_rest_state()
	var current_actor = conversation_manager.get_current_actor()
	var previous_actor = conversation_manager.get_previous_actor()
	var data = get_follow_parameters(
		point_of_interest if point_of_interest else (
			current_actor
				if current_actor and not equals(current_actor)
				else (
					previous_actor
						if previous_actor and not equals(previous_actor)
						else get_preferred_target()
				)
		),
		current_transform,
		target_node.get_global_transform().origin
			if target_node and point_of_interest and target_node.get_instance_id() == point_of_interest.get_instance_id()
			else next_position
	)
	var d = data.get_distance()
	var zero_rotation = is_zero_rotation(data.get_rotation_angle())
	
	if not in_party \
		and d > ALIGNMENT_RANGE \
		and target_node \
		and zero_rotation \
		and is_arrived_to_boundary(target_node):
		return data \
			.clear_dir() \
			.with_rest_state(true) \
			.with_signal("arrived_to_boundary", [target_node])
	elif not path.empty():
		data.with_rest_state(false)
		if d <= ALIGNMENT_RANGE:
			path.pop_front()
			data.clear_dir()
	elif in_party and d > FOLLOW_RANGE:
		data.with_rest_state(false)
	elif in_party and d > CLOSEUP_RANGE and was_moving:
		data.with_rest_state(false)
	else:
		if in_party:
			if not cutscene_manager.is_cutscene():
				data.clear_rotation_angle()
			return data.clear_dir().with_rest_state(zero_rotation)
		elif was_moving and target_node and zero_rotation and d <= ALIGNMENT_RANGE:
			return data \
				.clear_dir() \
				.with_rest_state(true) \
				.with_signal("arrived_to", [target_node])
	return data

func update_navpath(pstart, pend):
	path = get_navpath(pstart, pend)
	if DRAW_PATH:
		draw_path()

func get_navpath(pstart, pend):
	if not pathfinding_enabled:
		return []
	var p1 = navigation_node.get_closest_point(pstart)
	var p2 = navigation_node.get_closest_point(pend)
	var p = navigation_node.get_simple_path(p1, p2, true)
	return Array(p) # Vector3array too complex to use, convert to regular array

func has_path():
	return not path.empty()

func build_path(target_position):
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
	for ch in navigation_node.get_node("path_holder").get_children():
		navigation_node.get_node("path_holder").remove_child(ch)
	var k = 1.0
	for p in path:
		var m = MeshInstance.new()
		m.mesh = SphereMesh.new()
		m.mesh.radius = 0.1 * k
		k = k + 0.1
		navigation_node.get_node("path_holder").add_child(m)
		m.global_translate(p)

func clear_path():
	for ch in navigation_node.get_node("path_holder").get_children():
		navigation_node.get_node("path_holder").remove_child(ch)
	path.clear()

func get_distance_to(pos):
	if pos:
		var current_position = get_global_transform().origin
		var mov_vec = pos - current_position
		mov_vec.y = 0
		return mov_vec.length()
	else:
		return 0.0

func get_distance_to_target():
	return get_distance_to(get_target_position())

func get_distance_to_character(character):
	return get_distance_to(character.get_global_transform().origin)

func shadow_casting_enable(enable):
	common_utils.shadow_casting_enable(self, enable)

func get_movement_data(is_player):
	var data = PLDMovementData.new().with_rest_state(rest_state)
	if not is_activated():
		return data
	var target_position = get_target_position()
	if not target_position:
		return data
	var current_transform = get_global_transform()
	if not is_player or not in_party or cutscene_manager.is_cutscene():
		build_path(target_position)
		return follow(current_transform, path.front() if path.size() > 0 else target_position)
	
	return data

func update_state(data : PLDMovementData):
	if not is_player_controlled():
		angle_rad_y = 0
	if data.has_rotation_angle():
		if not in_party or not is_rest_state():
			if data.get_rotation_angle() > ROTATION_ANGLE_MIN_RAD:
				angle_rad_y = deg2rad(KEY_LOOK_SPEED_FACTOR * settings.get_sensitivity())
			elif data.get_rotation_angle() < -ROTATION_ANGLE_MIN_RAD:
				angle_rad_y = deg2rad(KEY_LOOK_SPEED_FACTOR * settings.get_sensitivity() * -1)
	if data.has_rest_state(): 
		var rest_state_new = data.get_rest_state()
		if rest_state != rest_state_new:
			rest_state = rest_state_new
			emit_signal("rest_state_changed", self, rest_state, rest_state_new)
	data.emit_sgnl_if_exists(self)

func _on_character_dead(player):
	if equals(player):
		deactivate()

func _on_character_dying(player):
	pass
