extends PLDPathfinder
class_name PLDCharacter

signal arrived_to(player_node, target_node)
signal arrived_to_boundary(player_node, target_node)

const GRAVITY = -6.2
const MAX_SPEED = 3
const MAX_SPRINT_SPEED = 10
const JUMP_SPEED = 4.5
const ACCEL= 1.5
const DEACCEL= 16
const SPRINT_ACCEL = 4.5
const MIN_MOVEMENT = 0.01

const FOLLOW_RANGE = 3
const CLOSEUP_RANGE = 2
const ALIGNMENT_RANGE = 0.2

const UP_DIR = Vector3(0, 1, 0)
const Z_DIR = Vector3(0, 0, 1)
const ZERO_DIR = Vector3(0, 0, 0)
const PUSH_STRENGTH = 10
const NONCHAR_PUSH_STRENGTH = 2
const NONCHAR_COLLISION_RANGE_MAX = 5.9

const MAX_SLOPE_ANGLE = 60
const AXIS_VALUE_THRESHOLD = 0.15
const MOUSE_SENSITIVITY = 0.1 #0.05
const KEY_LOOK_SPEED_FACTOR = 30

const DRAW_PATH = false
const SOUND_PATH_TEMPLATE = "res://sound/environment/%s"

enum SoundId {SOUND_WALK_NONE, SOUND_WALK_SAND, SOUND_WALK_GRASS, SOUND_WALK_CONCRETE}
enum COMPANION_STATE {REST, WALK, RUN}

export var name_hint = game_params.PLAYER_NAME_HINT
export var model_path = "res://scenes/female.tscn"

onready var upper_body_shape = $UpperBody_CollisionShape
onready var body_shape = $Body_CollisionShape
onready var rotation_helper = $Rotation_Helper
onready var standing_area = $StandingArea
onready var pyramid = get_parent()
onready var sound = {
	SoundId.SOUND_WALK_NONE : null,
	SoundId.SOUND_WALK_SAND : load(SOUND_PATH_TEMPLATE % "161815__dasdeer__sand-walk.ogg"),
	SoundId.SOUND_WALK_GRASS : load(SOUND_PATH_TEMPLATE % "400123__harrietniamh__footsteps-on-grass.ogg"),
	SoundId.SOUND_WALK_CONCRETE : load(SOUND_PATH_TEMPLATE % "336598__inspectorj__footsteps-concrete-a.ogg")
}

var angle_rad_x = 0
var angle_rad_y = 0
var vel = Vector3()
var dir = Vector3()

var is_walking = false
var is_crouching = false
var is_sprinting = false
var is_in_jump = false
var companion_state = COMPANION_STATE.REST

var target_node = null
var pathfinding_enabled = true

var path = []

func _ready():
	var model_container = get_node("Model")
	var placeholder = get_node("placeholder")
	placeholder.visible = false  # placeholder.queue_free() breaks directional shadows for some weird reason :/
	var model = load(model_path).instance()
	model_container.add_child(model)
	game_params.register_player(self)

### Getting character's parts ###

func get_name_hint():
	return name_hint

func get_model_holder():
	return get_node("Model")

func get_model():
	return get_model_holder().get_child(0)

### Use target ###

func add_highlight(player_node):
	return ""

func remove_highlight(player_node):
	pass

func use(player_node):
	pass

### States ###

func is_in_party():
	return game_params.is_in_party(name_hint)

func rest():
	get_model().look(0)

func set_look_transition(force = false):
	if force \
		or conversation_manager.meeting_is_in_progress(name_hint, game_params.PLAYER_NAME_HINT) \
		or conversation_manager.meeting_is_finished(name_hint, game_params.PLAYER_NAME_HINT):
		get_model().set_look_transition(PLDCharacterModel.LOOK_TRANSITION_SQUATTING if is_crouching else PLDCharacterModel.LOOK_TRANSITION_STANDING)

func play_cutscene(cutscene_id):
	get_model().play_cutscene(cutscene_id)
	$CutsceneTimer.start()

func stop_cutscene():
	get_model().stop_cutscene()

func is_cutscene():
	return get_model().is_cutscene()

func get_target_node():
	return target_node

func set_target_node(node):
	target_node = node

func get_preferred_target():
	return target_node if not is_in_party() else (game_params.get_companion() if is_player() else game_params.get_player())

func get_target_position():
	var t = get_preferred_target()
	return t.get_global_transform().origin if t else null

func is_player():
	return game_params.get_player().get_instance_id() == self.get_instance_id()

func is_player_controlled():
	return is_in_party() and is_player()

func is_rest_state():
	return companion_state == COMPANION_STATE.REST

func is_walk_state():
	return companion_state == COMPANION_STATE.WALK

func set_pathfinding_enabled(enabled):
	pathfinding_enabled = enabled

func has_collisions():
	var sc = get_slide_count()
	for i in range(0, sc):
		var collision = get_slide_collision(i)
		if not collision.collider.get_collision_mask_bit(2):
			return true
	return false

func sit_down():
	if $AnimationPlayer.is_playing():
		return
	get_model().sit_down()
	$AnimationPlayer.play("crouch")
	var is_player = is_player()
	if is_player:
		var companions = game_params.get_companions()
		for companion in companions:
			companion.sit_down()
	is_sprinting = false
	is_crouching = true
	if is_player:
		var hud = game_params.get_hud()
		if hud:
			hud.set_crouch_indicator(true)

func is_low_ceiling():
	# Make sure you've set proper collision layer bit for ceiling
	return standing_area.get_overlapping_bodies().size() > 0

func stand_up():
	if $AnimationPlayer.is_playing():
		return
	if is_low_ceiling():
		# I.e. if the player is crouching and something is above the head, do not allow to stand up.
		return
	get_model().stand_up()
	$AnimationPlayer.play_backwards("crouch")
	var is_player = is_player()
	if is_player:
		var companions = game_params.get_companions()
		for companion in companions:
			companion.stand_up()
	is_crouching = false
	if is_player:
		var hud = game_params.get_hud()
		if hud:
			hud.set_crouch_indicator(false)

func is_crouching():
	return is_crouching

func toggle_crouch():
	stand_up() if is_crouching else sit_down()

func set_sprinting(enable):
	is_sprinting = enable
	var is_player = is_player()
	if is_player:
		var companions = game_params.get_companions()
		for companion in companions:
			companion.set_sprinting(enable)

func teleport(node_to):
	if node_to:
		clear_path()
		set_global_transform(node_to.get_global_transform())

func set_sound_walk(mode):
	var spl = $SoundWalking
	spl.stop()
	spl.stream = sound[mode] if sound.has(mode) else null
	spl.set_unit_db(0)

func shadow_casting_enable(enable):
	common_utils.shadow_casting_enable(self, enable)

### Player/target following ###

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

func get_follow_parameters(node_to_follow_pos, current_transform, next_position):
	var was_moving = companion_state != COMPANION_STATE.REST
	var current_position = current_transform.origin
	var in_party = is_in_party()
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
		"was_moving" : was_moving,
		"next_dir" : next_dir,
		"rotation_angle" : rotation_angle,
		"rotation_angle_to_target_deg" : rotation_angle_to_target_deg
	}

func follow(current_transform, next_position):
	var p = get_follow_parameters(game_params.get_player().get_global_transform().origin, current_transform, next_position)
	var was_moving = p.was_moving
	var next_dir = p.next_dir
	var distance = next_dir.length()
	var rotation_angle = p.rotation_angle
	var rotation_angle_to_target_deg = p.rotation_angle_to_target_deg
	
	var in_party = is_in_party()
	angle_rad_y = 0
	if not in_party or is_walk_state():
		if rotation_angle > 0.1:
			angle_rad_y = deg2rad(KEY_LOOK_SPEED_FACTOR * MOUSE_SENSITIVITY)
		elif rotation_angle < -0.1:
			angle_rad_y = deg2rad(KEY_LOOK_SPEED_FACTOR * MOUSE_SENSITIVITY * -1)
	
	var model = get_model()
	if not path.empty():
		companion_state = COMPANION_STATE.WALK
		model.walk(rotation_angle_to_target_deg, is_crouching, is_sprinting)
		if distance <= ALIGNMENT_RANGE:
			path.pop_front()
			dir = Vector3()
		else:
			dir = next_dir.normalized()
		if not $SoundWalking.is_playing():
			$SoundWalking.play()
	elif in_party and distance > FOLLOW_RANGE:
		companion_state = COMPANION_STATE.WALK
		model.walk(rotation_angle_to_target_deg, is_crouching, is_sprinting)
		dir = next_dir.normalized()
		if not $SoundWalking.is_playing():
			$SoundWalking.play()
	elif (in_party and distance > CLOSEUP_RANGE and is_walk_state()) or (not in_party and distance > ALIGNMENT_RANGE):
		if was_moving and not in_party and target_node and angle_rad_y == 0 and get_slide_count() > 0:
			var collision = get_slide_collision(0)
			if collision.collider_id == target_node.get_instance_id():
				companion_state = COMPANION_STATE.REST
				emit_signal("arrived_to_boundary", self, target_node)
				model.look(rotation_angle_to_target_deg)
				dir = Vector3()
				return
		companion_state = COMPANION_STATE.WALK
		model.walk(rotation_angle_to_target_deg, is_crouching, is_sprinting)
		dir = next_dir.normalized()
		if not $SoundWalking.is_playing():
			$SoundWalking.play()
	else:
		model.look(rotation_angle_to_target_deg)
		dir = Vector3()
		if in_party:
			companion_state = COMPANION_STATE.REST
		else:
			if was_moving and target_node and angle_rad_y == 0 and distance <= ALIGNMENT_RANGE:
				companion_state = COMPANION_STATE.REST
				emit_signal("arrived_to", self, target_node)

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

func set_dir(dir):
	self.dir = dir

func reset_movement():
	dir = Vector3()
	set_sprinting(false)

func reset_rotation():
	angle_rad_x = 0
	angle_rad_y = 0
	rotation_helper.set_rotation_degrees(Vector3(0, 0, 0))
	get_model_holder().set_rotation_degrees(Vector3(0, 0, 0))
	upper_body_shape.set_rotation_degrees(Vector3(-90, 0, 0))

func reset_movement_and_rotation():
	reset_movement()
	reset_rotation()

func process_rotation(need_to_update_collisions):
	if angle_rad_x != 0 or angle_rad_y != 0:
		if need_to_update_collisions:
			move_and_slide(ZERO_DIR, ZERO_DIR, true, 4, deg2rad(MAX_SLOPE_ANGLE), is_in_party())
		rotation_helper.rotate_x(angle_rad_x)
		get_model_holder().rotate_x(angle_rad_x)
		upper_body_shape.rotate_x(angle_rad_x)
		self.rotate_y(angle_rad_y)

func process_movement(delta):
	dir.y = 0
	dir = dir.normalized()

	vel.y += delta*GRAVITY

	var hvel = vel
	hvel.y = 0

	var target = dir
	if is_sprinting:
		target *= MAX_SPRINT_SPEED
	else:
		target *= MAX_SPEED

	var accel
	if dir.dot(hvel) > 0:
		if is_sprinting:
			accel = SPRINT_ACCEL
		else:
			accel = ACCEL
	else:
		accel = DEACCEL

	hvel = hvel.linear_interpolate(target, accel*delta)
	vel.x = hvel.x
	vel.z = hvel.z
	
	vel = move_and_slide_with_snap(vel, ZERO_DIR if is_in_jump else UP_DIR, UP_DIR, true, 4, deg2rad(MAX_SLOPE_ANGLE), is_in_party())
	is_walking = vel.length() > MIN_MOVEMENT
	if is_walking:
		if not $SoundWalking.is_playing():
			$SoundWalking.play()
		$SoundWalking.pitch_scale = 2 if is_sprinting else 1
	else:
		$SoundWalking.stop()
	
	var sc = get_slide_count()
	var character_collisions = []
	var nonchar_collision = null
	var characters = [] if sc == 0 else game_params.get_characters()
	for i in range(0, sc):
		var collision = get_slide_collision(i)
		var has_char_collision = false
		for character in characters:
			if collision.collider_id == character.get_instance_id():
				has_char_collision = true
				character_collisions.append(collision)
				break
		if not has_char_collision and not collision.collider.get_collision_mask_bit(2):
			nonchar_collision = collision
	for collision in character_collisions:
		var character = collision.collider
		if not character.is_cutscene() and not character.is_player_controlled():
			character.vel = get_out_vec(-collision.normal) * PUSH_STRENGTH
			character.vel.y = 0

	if is_player_controlled():
		if is_walking:
			get_model().walk(0, is_crouching, is_sprinting)
		else:
			rest()
	elif nonchar_collision and pathfinding_enabled:
		var v = get_out_vec(nonchar_collision.normal) * NONCHAR_PUSH_STRENGTH
		clear_path()
		var current_position = get_global_transform().origin
		var start_position = current_position + v
		var target_position = get_target_position()
		if target_position:
			update_navpath(start_position, target_position)
		path.push_front(start_position)
		if DRAW_PATH:
			draw_path()
	return is_walking

func get_out_vec(normal):
	var n = normal
	n.y = 0
	var cross = UP_DIR.cross(n)
	var coeff = rand_range(-NONCHAR_COLLISION_RANGE_MAX, NONCHAR_COLLISION_RANGE_MAX)
	return (n + coeff * cross).normalized()

func _physics_process(delta):
	var in_party = is_in_party()
	if is_low_ceiling() and not is_crouching and is_on_floor():
		sit_down()
	if not is_player() or not in_party:
		if is_cutscene():
			return
		var target_position = get_target_position()
		if target_position:
			var current_transform = get_global_transform()
			var current_position = current_transform.origin
			build_path(target_position, in_party)
			follow(current_transform, path.front() if path.size() > 0 else target_position)
	
	var is_moving = process_movement(delta)
	process_rotation(not is_moving)

func _on_HealTimer_timeout():
	if is_player():
		game_params.set_health(name_hint, game_params.player_health_current + game_params.HEALING_RATE, game_params.player_health_max)

func _on_CutsceneTimer_timeout():
	set_look_transition(true)
