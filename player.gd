extends KinematicBody
class_name PalladiumPlayer

signal arrived_to(player_node, target_node)
signal arrived_to_boundary(player_node, target_node)

const PLAYER_NAME_HINT = "player"

export var initial_player = true
export var initial_companion = false
export var name_hint = PLAYER_NAME_HINT
export var model_path = "res://scenes/female.tscn"

const SOUND_WALK_NONE = 0
const SOUND_WALK_SAND = 1
const SOUND_WALK_GRASS = 2
const SOUND_WALK_CONCRETE = 3

const GRAVITY = -6.2
var vel = Vector3()
const MAX_SPEED = 5
const JUMP_SPEED = 4.5
const ACCEL= 1.5

const MAX_SPRINT_SPEED = 15
const SPRINT_ACCEL = 4.5

var dir = Vector3()

const DEACCEL= 16
const MAX_SLOPE_ANGLE = 60

onready var upper_body_shape = $UpperBody_CollisionShape
onready var body_shape = $Body_CollisionShape
onready var rotation_helper = $Rotation_Helper
onready var standing_area = $StandingArea

var is_walking = false
var is_crouching = false
var is_sprinting = false
var is_in_jump = false

var angle_rad_x = 0
var angle_rad_y = 0

var MOUSE_SENSITIVITY = 0.1 #0.05
var KEY_LOOK_SPEED_FACTOR = 30

#####

export var floor_path = "../StaticBodyFloor"
export var rotation_speed = 0.03
export var linear_speed = 2.8

onready var pyramid = get_parent()
onready var floor_node = get_node(floor_path)
const ANGLE_TOLERANCE = 0.01
const MIN_MOVEMENT = 0.01

const CONVERSATION_RANGE = 7
const FOLLOW_RANGE = 3
const CLOSEUP_RANGE = 2
const ALIGNMENT_RANGE = 0.2

const CAMERA_ROT_MIN_DEG = -88
const CAMERA_ROT_MAX_DEG = 88
const MODEL_ROT_MIN_DEG = -88
const MODEL_ROT_MAX_DEG = 0
const SHAPE_ROT_MIN_DEG = -90-88
const SHAPE_ROT_MAX_DEG = -90+88

var cur_animation = null
var UP_DIR = Vector3(0, 1, 0)
var Z_DIR = Vector3(0, 0, 1)
var ZERO_DIR = Vector3(0, 0, 0)
var PUSH_STRENGTH = 10

var path = []
var exclusions = []

enum COMPANION_STATE {REST, WALK, RUN}
var companion_state = COMPANION_STATE.REST
var target_node = null
var pathfinding_enabled = true

func set_pathfinding_enabled(enabled):
	pathfinding_enabled = enabled

func get_rotation_angle(cur_dir, target_dir):
	var c = cur_dir.normalized()
	var t = target_dir.normalized()
	var cross = c.cross(t)
	var clen = cross.length()
	if clen > 1.0:
		clen = 1.0
	return asin(clen) if cross.y > 0 else -asin(clen)

func follow(current_transform, next_position):
	var current_position = current_transform.origin
	var player_node = game_params.get_player()
	var in_party = is_in_party()
	var was_moving = companion_state != COMPANION_STATE.REST
	var cur_dir = current_transform.basis.xform(Z_DIR)
	cur_dir.y = 0
	var next_dir = next_position - current_position
	next_dir.y = 0
	var distance = next_dir.length()
	
	var rotation_angle = 0
	var rotation_angle_to_target_deg = 0
	var preferred_target = player_node if in_party else target_node
	if preferred_target:
		var t = preferred_target.get_global_transform()
		var target_position = t.origin
		var player_position = player_node.get_global_transform().origin
		var mov_vec = target_position - current_position if was_moving else player_position - current_position
		mov_vec.y = 0
		rotation_angle = get_rotation_angle(cur_dir, next_dir) \
							if in_party or distance > ALIGNMENT_RANGE \
							else get_rotation_angle(cur_dir, t.basis.xform(Z_DIR))
		rotation_angle_to_target_deg = rad2deg(get_rotation_angle(cur_dir, mov_vec))
	
	angle_rad_y = 0
	if not in_party or companion_state == COMPANION_STATE.WALK:
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
	elif (in_party and distance > CLOSEUP_RANGE and companion_state == COMPANION_STATE.WALK) or (not in_party and distance > ALIGNMENT_RANGE):
		if was_moving and not in_party and target_node and angle_rad_y == 0 and get_slide_count() > 0:
			var collision = get_slide_collision(0)
			if collision.collider_id == target_node.get_instance_id():
				emit_signal("arrived_to_boundary", self, target_node)
				companion_state = COMPANION_STATE.REST
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
				emit_signal("arrived_to", self, target_node)
				companion_state = COMPANION_STATE.REST

func is_in_speak_mode():
	return get_model().is_in_speak_mode()

func set_speak_mode(enable):
	get_model().set_speak_mode(enable)

func sit_down(force = false):
	if $AnimationPlayer.is_playing():
		return
	get_model().sit_down(force)
	$AnimationPlayer.play("crouch")
	var is_player = is_player()
	if is_player:
		var companions = game_params.get_companions()
		for companion in companions:
			companion.sit_down(force)
	is_crouching = true
	if is_player:
		var hud = game_params.get_hud()
		if hud:
			hud.set_crouch_indicator(true)

func stand_up(force = false):
	if $AnimationPlayer.is_playing():
		return
	if is_low_ceiling():
		# I.e. if the player is crouching and something is above the head, do not allow to stand up.
		return
	get_model().stand_up(force)
	$AnimationPlayer.play_backwards("crouch")
	var is_player = is_player()
	if is_player:
		var companions = game_params.get_companions()
		for companion in companions:
			companion.stand_up(force)
	is_crouching = false
	if is_player:
		var hud = game_params.get_hud()
		if hud:
			hud.set_crouch_indicator(false)

func get_navpath(pstart, pend):
	if not pathfinding_enabled:
		return []
	var p1 = pyramid.get_closest_point(pstart)
	var p2 = pyramid.get_closest_point(pend)
	var p = pyramid.get_simple_path(p1, p2, true)
	return Array(p) # Vector3array too complex to use, convert to regular array

func has_collisions():
	var sc = get_slide_count()
	for i in range(0, sc):
		var collision = get_slide_collision(i)
		if collision.collider_id != floor_node.get_instance_id():
			return true
	return false

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
		path = get_navpath(current_position, target_position)
		#draw_path()

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

func get_cam_holder():
	return get_node("Rotation_Helper/Camera")

func get_cam():
	var cutscene_cam = cutscene_manager.get_cam()
	return cutscene_cam if cutscene_cam else get_cam_holder().get_node("camera")

func use(player_node):
	if not conversation_manager.conversation_active():
		game_params.handle_conversation(player_node, self, player_node)

func get_model_holder():
	return get_node("Model")

func get_model():
	return get_model_holder().get_child(0)

func _input(event):
	if not is_player():
		return
	var hud = game_params.get_hud()
	var conversation = hud.conversation
	if conversation.is_visible_in_tree():
		if conversation_manager.in_choice and event.is_action_pressed("dialogue_next"):
			conversation_manager.proceed_story_immediately(self)
		elif event.is_action_pressed("dialogue_option_1"):
			conversation_manager.story_choose(self, 0)
		elif event.is_action_pressed("dialogue_option_2"):
			conversation_manager.story_choose(self, 1)
		elif event.is_action_pressed("dialogue_option_3"):
			conversation_manager.story_choose(self, 2)
		elif event.is_action_pressed("dialogue_option_4"):
			conversation_manager.story_choose(self, 3)
	if is_in_party() and not cutscene_manager.is_cutscene():
		if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			angle_rad_x = deg2rad(event.relative.y * MOUSE_SENSITIVITY)
			angle_rad_y = deg2rad(event.relative.x * MOUSE_SENSITIVITY * -1)
			process_rotation()
			angle_rad_x = 0
			angle_rad_y = 0
		else:
			if event.is_action_pressed("ui_up"):
				angle_rad_x = deg2rad(KEY_LOOK_SPEED_FACTOR * MOUSE_SENSITIVITY * -1)
			elif event.is_action_pressed("ui_down"):
				angle_rad_x = deg2rad(KEY_LOOK_SPEED_FACTOR * MOUSE_SENSITIVITY)
			elif event.is_action_released("ui_up") or event.is_action_released("ui_down"):
				angle_rad_x = 0
			
			if event.is_action_pressed("ui_left"):
				angle_rad_y = deg2rad(KEY_LOOK_SPEED_FACTOR * MOUSE_SENSITIVITY)
			elif event.is_action_pressed("ui_right"):
				angle_rad_y = deg2rad(KEY_LOOK_SPEED_FACTOR * MOUSE_SENSITIVITY * -1)
			elif event.is_action_released("ui_left") or event.is_action_released("ui_right"):
				angle_rad_y = 0

func process_rotation():
	rotation_helper.rotate_x(angle_rad_x)
	get_model_holder().rotate_x(angle_rad_x)
	upper_body_shape.rotate_x(angle_rad_x)
	self.rotate_y(angle_rad_y)
	var camera_rot = rotation_helper.rotation_degrees
	var model_rot = Vector3(camera_rot.x, camera_rot.y, camera_rot.z)
	var shape_rot = upper_body_shape.rotation_degrees
	camera_rot.x = clamp(camera_rot.x, CAMERA_ROT_MIN_DEG, CAMERA_ROT_MAX_DEG)
	rotation_helper.rotation_degrees = camera_rot
	model_rot.x = clamp(model_rot.x, MODEL_ROT_MIN_DEG, MODEL_ROT_MAX_DEG)
	get_model_holder().rotation_degrees = model_rot
	shape_rot.x = clamp(shape_rot.x, SHAPE_ROT_MIN_DEG, SHAPE_ROT_MAX_DEG)
	upper_body_shape.rotation_degrees = shape_rot

func add_highlight(player_node):
	#door_mesh.mesh.surface_set_material(surface_idx_door, null)
#	door_mesh.set_surface_material(surface_idx_door, outlined_material)
	var hud = game_params.get_hud()
	var inventory = hud.inventory
	var conversation = hud.conversation
	if conversation.visible:
		return ""
	return game_params.handle_player_highlight(player_node, self)

func remove_highlight(player_node):
#	door_mesh.set_surface_material(surface_idx_door, null)
	#door_mesh.mesh.surface_set_material(surface_idx_door, material)
	pass

#####

func is_player():
	return game_params.get_player().get_instance_id() == self.get_instance_id()

func become_player():
	if is_player():
		get_cam().rebuild_exceptions(self)
		return
	var player = game_params.get_player()
	var rotation_helper = get_node("Rotation_Helper")
	var camera_container = rotation_helper.get_node("Camera")
	var player_rotation_helper = player.get_node("Rotation_Helper")
	var player_camera_container = player_rotation_helper.get_node("Camera")
	var camera = player_camera_container.get_child(0)
	player_camera_container.remove_child(camera)
	camera_container.add_child(camera)
	var player_model = player.get_model()
	player_model.set_simple_mode(false)
	var model = get_model()
	model.set_simple_mode(true)
	player.reset_rotation()
	game_params.set_player_name_hint(name_hint)
	camera.rebuild_exceptions(self)

func reset_rotation():
	rotation_helper.set_rotation_degrees(Vector3(0, 0, 0))
	get_model_holder().set_rotation_degrees(Vector3(0, 0, 0))
	upper_body_shape.set_rotation_degrees(Vector3(-90, 0, 0))

func _ready():
	exclusions.append(self)
	exclusions.append(floor_node)
	exclusions.append($UpperBody_CollisionShape)  # looks like it is not included, but to be sure...
	exclusions.append($Body_CollisionShape)
	exclusions.append($Feet_CollisionShape)
	if initial_player:
		var camera = load("res://camera.tscn").instance()
		get_cam_holder().add_child(camera)
		camera.rebuild_exceptions(self)
		game_params.set_player_name_hint(name_hint)
	var model_container = get_node("Model")
	var placeholder = get_node("placeholder")
	placeholder.visible = false  # placeholder.queue_free() breaks directional shadows for some weird reason :/
	var model = load(model_path).instance()
	model.set_simple_mode(initial_player)
	model_container.add_child(model)
	game_params.register_player(self)

func _on_item_taken(nam, cnt):
	if not is_player():
		return
	var hud = game_params.get_hud()
	if hud:
		hud.synchronize_items()

func _on_item_removed(nam, cnt):
	if not is_player():
		return
	var hud = game_params.get_hud()
	if hud:
		hud.synchronize_items()

func remove_item_from_hand():
	get_model().remove_item_from_hand()

func join_party():
	game_params.join_party(name_hint)
	dir = Vector3()
	angle_rad_x = 0
	angle_rad_y = 0

func set_simple_mode(enable):
	get_model().set_simple_mode(enable)

func rest():
	get_model().look(0)

func play_cutscene(cutscene_id):
	get_model().play_cutscene(cutscene_id)

func stop_cutscene():
	get_model().stop_cutscene()

func leave_party():
	game_params.leave_party(name_hint)

func is_in_party():
	return game_params.is_in_party(name_hint)

func is_cutscene():
	return get_model().is_cutscene()

func set_target_node(node):
	target_node = node

func get_preferred_target():
	return game_params.get_player() if is_in_party() else target_node

func get_target_position():
	var t = get_preferred_target()
	return t.get_global_transform().origin if t else null

func teleport(node_to):
	if node_to:
		set_global_transform(node_to.get_global_transform())

func _physics_process(delta):
	var in_party = is_in_party()
	if is_low_ceiling() and not is_crouching and is_on_floor():
		toggle_crouch()
	if is_player() and in_party:
		if cutscene_manager.is_cutscene():
			$SoundWalking.stop()
			return
		process_input(delta)
	else:
		if is_cutscene() and in_party:
			return
		var target_position = get_target_position()
		if not target_position:
			return
		var current_transform = get_global_transform()
		var current_position = current_transform.origin
		build_path(target_position, in_party)
		follow(current_transform, path.front() if path.size() > 0 else target_position)
	
	process_movement(delta)
	process_rotation()

func process_input(delta):

	# ----------------------------------
	# Walking
	dir = Vector3()
	var camera = get_cam_holder().get_node("camera")
	var cam_xform = camera.get_global_transform()

	var input_movement_vector = Vector2()

	if Input.is_action_pressed("movement_forward"):
		input_movement_vector.y += 1
	if Input.is_action_pressed("movement_backward"):
		input_movement_vector.y -= 1
	if Input.is_action_pressed("movement_left"):
		input_movement_vector.x -= 1
	if Input.is_action_pressed("movement_right"):
		input_movement_vector.x += 1

	input_movement_vector = input_movement_vector.normalized()
	is_walking = input_movement_vector.length() > 0

	dir += -cam_xform.basis.z.normalized() * input_movement_vector.y
	dir += cam_xform.basis.x.normalized() * input_movement_vector.x
	# ----------------------------------

	# ----------------------------------
	# Jumping
	if is_on_floor():
		if Input.is_action_just_pressed("movement_jump"):
			vel.y = JUMP_SPEED
			is_in_jump = true
		else:
			if is_in_jump:
				$SoundFallingToFloor.play()
				is_in_jump = false
	# ----------------------------------
	
	# ----------------------------------
	# Sprinting
	if Input.is_action_pressed("movement_sprint"):
		set_sprinting(true)
	else:
		set_sprinting(false)
	# ----------------------------------
	
	# ----------------------------------
	# Crouching on/off
	if Input.is_action_just_pressed("crouch"):
		toggle_crouch()
	# ----------------------------------

func set_sprinting(enable):
	is_sprinting = enable
	var is_player = is_player()
	if is_player:
		var companions = game_params.get_companions()
		for companion in companions:
			companion.set_sprinting(enable)

func is_low_ceiling():
	# Make sure you've set proper collision layer bit for ceiling
	return standing_area.get_overlapping_bodies().size() > 0

func toggle_crouch():
	stand_up() if is_crouching else sit_down()

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
	var is_moving = is_in_jump or vel.x > MIN_MOVEMENT or vel.x < -MIN_MOVEMENT or vel.z > MIN_MOVEMENT or vel.z < -MIN_MOVEMENT
	if not is_moving:
		$SoundWalking.stop()
		return
	
	if not $SoundWalking.is_playing():
		$SoundWalking.play()
	$SoundWalking.pitch_scale = 2 if is_sprinting else 1

	vel = move_and_slide_with_snap(vel, ZERO_DIR if is_in_jump else UP_DIR, UP_DIR, true, 4, deg2rad(MAX_SLOPE_ANGLE), is_in_party())

	var sc = get_slide_count()
	if sc == 0:
		return
	var character_collisions = []
	var nonchar_collision = null
	var characters = game_params.get_characters()
	for i in range(0, sc):
		var collision = get_slide_collision(i)
		var has_char_collision = false
		for character in characters:
			if collision.collider_id == character.get_instance_id():
				has_char_collision = true
				character_collisions.append(collision)
				break
		if not has_char_collision and collision.collider_id != floor_node.get_instance_id():
			nonchar_collision = collision
	for collision in character_collisions:
		var character = collision.collider
		if not character.is_cutscene() and not character.is_player_controlled():
			character.vel = -collision.normal * PUSH_STRENGTH
			character.vel.y = 0

	if is_player_controlled():
		return
	elif nonchar_collision and pathfinding_enabled:
		vel = nonchar_collision.normal * PUSH_STRENGTH
		vel.y = 0
		clear_path()
		var current_position = get_global_transform().origin
		var target_position = get_target_position()
		path = get_navpath(current_position, target_position)

func is_player_controlled():
	return is_in_party() and is_player()

func set_sound_walk(mode):
	var spl = $SoundWalking
	spl.stop()
	if mode == SOUND_WALK_NONE:
		spl.stream = null
		spl.set_unit_db(0)
		return
	var sound_file = File.new()
	match mode:
		SOUND_WALK_SAND:
			sound_file.open("res://sound/environment/161815__dasdeer__sand-walk.ogg", File.READ)
			spl.set_unit_db(0)
		SOUND_WALK_GRASS:
			sound_file.open("res://sound/environment/400123__harrietniamh__footsteps-on-grass.ogg", File.READ)
			spl.set_unit_db(0)
		SOUND_WALK_CONCRETE:
			sound_file.open("res://sound/environment/336598__inspectorj__footsteps-concrete-a.ogg", File.READ)
			spl.set_unit_db(0)
		_:
			sound_file.open("res://sound/environment/336598__inspectorj__footsteps-concrete-a.ogg", File.READ)
			spl.set_unit_db(0)
	var bytes = sound_file.get_buffer(sound_file.get_len())
	var stream = AudioStreamOGGVorbis.new()
	stream.data = bytes
	spl.stream = stream

func shadow_casting_enable(enable):
	common_utils.shadow_casting_enable(self, enable)