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

onready var body_shape = $Body_CollisionShape
onready var rotation_helper = $Rotation_Helper
onready var model = rotation_helper.get_node("Model")

var is_walking = false
var is_crouching = false
var is_sprinting = false
var is_in_jump = false

var rot_x = 0
var rot_y = 0

var MOUSE_SENSITIVITY = 0.1 #0.05
var KEY_LOOK_SPEED_FACTOR = 30

#####

export var floor_path = "../StaticBodyFloor"
export var rotation_speed = 0.03
export var linear_speed = 2.8

onready var pyramid = get_parent()
const ANGLE_TOLERANCE = 0.01

const CONVERSATION_RANGE = 7
const FOLLOW_RANGE = 3
const CLOSEUP_RANGE = 2
const ALIGNMENT_RANGE = 0.2

var cur_animation = null
var up_dir = Vector3(0, 1, 0)
var z_dir = Vector3(0, 0, 1)
var zero_dir = Vector3(0, 0, 0)

var path = []
var exclusions = []

enum COMPANION_STATE {REST, WALK, RUN}
var companion_state = COMPANION_STATE.REST
var target_node = null

func get_rotation_angle(cur_dir, target_dir, force_forward = true):
	var c = cur_dir.normalized()
	var t = target_dir.normalized()
	var cross = c.cross(t)
#	var dot1 = cur_dir.dot(target_dir)
#	var dot2 = (-cur_dir).dot(target_dir)
#	if dot1 > 0 or force_forward:
#		return acos(dot1) if cross.y > 0 else -acos(dot1)
#	else:
#		return acos(dot2) if cross.y < 0 else -acos(dot2)
	var clen = cross.length()
	if clen > 1.0:
		clen = 1.0
	elif clen < -1.0:
		clen = -1.0
	return asin(clen) if cross.y > 0 else -asin(clen)

func follow(current_transform, target_position):
	var cur_dir = current_transform.basis.xform(z_dir)
	cur_dir.y = 0
	var target_dir = target_position - current_transform.origin
	target_dir.y = 0
	var distance = target_dir.length()
	var rotation_angle = get_rotation_angle(cur_dir, target_dir)
#	var step = state.get_step()
#	if step > 0.01 or step < -0.01: # To prevent division by zero
#		state.set_angular_velocity(up_dir * (rotation_angle / step) * rotation_speed)

	# Angle to player
	var current_position = current_transform.origin
	var player_position = game_params.get_player().get_global_transform().origin
	var mov_vec = player_position - current_position
	mov_vec.y = 0
	var rotation_angle_to_player_deg = rad2deg(get_rotation_angle(cur_dir, mov_vec))

	rot_y = 0
	if companion_state == COMPANION_STATE.WALK:
		if rotation_angle > 0.1:
			rot_y = -1
		elif rotation_angle < -0.1:
			rot_y = 1
	
#	if is_attacking:
#		return
	
	var model = get_model()
	var in_party = is_in_party()
	if not path.empty():
		companion_state = COMPANION_STATE.WALK
		model.walk(rotation_angle_to_player_deg)
		if distance <= ALIGNMENT_RANGE:
			path.pop_front()
			dir = Vector3()
		else:
			dir = target_dir.normalized()
		if not $SoundWalking.is_playing():
			$SoundWalking.play()
	elif in_party and distance > FOLLOW_RANGE:
		companion_state = COMPANION_STATE.WALK
		model.walk(rotation_angle_to_player_deg)
		dir = target_dir.normalized()
		if not $SoundWalking.is_playing():
			$SoundWalking.play()
	elif (in_party and distance > CLOSEUP_RANGE and companion_state == COMPANION_STATE.WALK) or (not in_party and distance > ALIGNMENT_RANGE):
		companion_state = COMPANION_STATE.WALK
		if not in_party and target_node and get_slide_count() > 0:
			var collision = get_slide_collision(0)
			if collision.collider == target_node:
				emit_signal("arrived_to_boundary", self, target_node)
				target_node = null
				companion_state = COMPANION_STATE.REST
				model.look(rotation_angle_to_player_deg)
				dir = Vector3()
				return
		model.walk(rotation_angle_to_player_deg)
		dir = target_dir.normalized()
		if not $SoundWalking.is_playing():
			$SoundWalking.play()
	else:
#		aggression_level = 0
		companion_state = COMPANION_STATE.REST
		model.look(rotation_angle_to_player_deg)
#		state.set_angular_velocity(zero_dir)
		dir = Vector3()
		if not in_party:
			var preferred_target = get_preferred_target()
			if preferred_target:
				var target_z = preferred_target.get_global_transform().basis.xform(z_dir)
				var c = cur_dir.normalized()
				var t = target_z.normalized()
				var cross = c.cross(t)
				if cross.y > 0.1:
					rot_y = -1
				elif cross.y < -0.1:
					rot_y = 1
			if target_node and current_position.distance_to(target_node.get_global_transform().origin) <= ALIGNMENT_RANGE:
				emit_signal("arrived_to", self, target_node)
				target_node = null

func is_in_speak_mode():
	return get_model().is_in_speak_mode()

func set_speak_mode(enable):
	get_model().set_speak_mode(enable)

func sit_down(force = false):
	get_model().sit_down(force)

func stand_up(force = false):
	get_model().stand_up(false)

func get_navpath(pstart, pend):
	var p1 = pyramid.get_closest_point(pstart)
	var p2 = pyramid.get_closest_point(pend)
	var p = pyramid.get_simple_path(p1, p2, true)
	return Array(p) # Vector3array too complex to use, convert to regular array

func has_collisions():
	var sc = get_slide_count()
	var floor_node = get_node(floor_path)
	for i in range(0, sc):
		var collision = get_slide_collision(i)
		if collision.collider != floor_node:
			return true
	return false

func build_path(target_position, in_party):
	var current_transform = get_global_transform()
	var current_position = current_transform.origin
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
		path = get_navpath(get_global_transform().origin, target_position)
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

func get_hud_holder():
	return get_node("HUD")

func get_cam_holder():
	return get_node("Rotation_Helper/Camera")

func get_hud():
	return get_hud_holder().get_node("hud")

func get_cam():
	var cutscene_cam = conversation_manager.get_cam()
	return cutscene_cam if cutscene_cam else get_cam_holder().get_node("camera")

func use(player_node):
	if not conversation_manager.conversation_active():
		game_params.handle_conversation(player_node, self)

func get_model():
	return get_node("Rotation_Helper/Model").get_child(0)

func _unhandled_input(event):
	if not is_player():
		return
	var is_key = event is InputEventKey and event.is_pressed()
	if not is_key:
		return
	var hud = get_hud()
	var conversation = hud.conversation
	if conversation.is_visible_in_tree():
		if conversation_manager.in_choice and event.scancode == KEY_1:
			conversation_manager.proceed_story_immediately(self)
		elif event.scancode >= KEY_1 and event.scancode <= KEY_9:
			conversation_manager.story_choose(self, event.scancode - KEY_1)

func add_highlight(player_node):
	#door_mesh.mesh.surface_set_material(surface_idx_door, null)
#	door_mesh.set_surface_material(surface_idx_door, outlined_material)
	var hud = player_node.get_hud()
	var inventory = hud.inventory
	var conversation = hud.conversation
	if conversation.visible:
		return ""
	return game_params.handle_player_highlight(player_node)

func remove_highlight(player_node):
#	door_mesh.set_surface_material(surface_idx_door, null)
	#door_mesh.mesh.surface_set_material(surface_idx_door, material)
	pass

#####

func is_player():
	return game_params.get_player() == self

func become_player():
	if is_player():
		return
	var player = game_params.get_player()
	var hud_container = get_hud_holder()
	var player_hud_container = player.get_hud_holder()
	var hud = player_hud_container.get_child(0)
	player_hud_container.remove_child(hud)
	hud_container.add_child(hud)
	var rotation_helper = get_node("Rotation_Helper")
	var camera_container = rotation_helper.get_node("Camera")
	var player_rotation_helper = player.get_node("Rotation_Helper")
	var player_camera_container = player_rotation_helper.get_node("Camera")
	var camera = player_camera_container.get_child(0)
	player_camera_container.remove_child(camera)
	camera_container.add_child(camera)
	var player_model_container = player_rotation_helper.get_node("Model")
	var model_container = rotation_helper.get_node("Model")
	var player_model = player_model_container.get_child(0)
	player_model.set_simple_mode(false)
	var model = model_container.get_child(0)
	model.set_simple_mode(true)
	player.reset_rotation()
	game_params.set_player_name_hint(name_hint)

func reset_rotation():
	var rotation_helper = get_node("Rotation_Helper")
	if rotation_helper:
		rotation_helper.set_rotation_degrees(Vector3(0, 0, 0))

func _ready():
	exclusions.append(self)
	var floor_node = get_node(floor_path)
	exclusions.append(floor_node)
	exclusions.append($Body_CollisionShape)  # looks like it is not included, but to be sure...
	exclusions.append($Feet_CollisionShape)
	if initial_player:
		var hud_container = get_hud_holder()
		var hud = load("res://hud.tscn").instance()
		hud_container.add_child(hud)
		var camera_container = get_node("Rotation_Helper/Camera")
		var camera = load("res://camera.tscn").instance()
		camera_container.add_child(camera)
		game_params.set_player_name_hint(name_hint)
	var model_container = get_node("Rotation_Helper/Model")
	var placeholder = get_node("Rotation_Helper/placeholder")
	placeholder.visible = false  # placeholder.queue_free() breaks directional shadows for some weird reason :/
	var model = load(model_path).instance()
	model.set_simple_mode(initial_player)
	model_container.add_child(model)
	game_params.register_player(self)

func _on_item_taken(nam, cnt):
	if not is_player():
		return
	var hud = get_hud()
	if hud:
		hud.synchronize_items()

func _on_item_removed(nam, cnt):
	if not is_player():
		return
	var hud = get_hud()
	if hud:
		hud.synchronize_items()

func remove_item_from_hand():
	get_model().remove_item_from_hand()

func join_party():
	game_params.join_party(name_hint)
	dir = Vector3()

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
	if is_player() and in_party:
		if conversation_manager.conversation_is_cutscene():
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
	if rot_x != 0:
		rotation_helper.rotate_x(deg2rad(rot_x * KEY_LOOK_SPEED_FACTOR * MOUSE_SENSITIVITY))
	if rot_y != 0:
		self.rotate_y(deg2rad(rot_y * KEY_LOOK_SPEED_FACTOR * MOUSE_SENSITIVITY * -1))

func _input(event):
	if is_player() and is_in_party() and not conversation_manager.conversation_is_cutscene():
		if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			rotation_helper.rotate_x(deg2rad(event.relative.y * MOUSE_SENSITIVITY))
			self.rotate_y(deg2rad(event.relative.x * MOUSE_SENSITIVITY * -1))
			var camera_rot = rotation_helper.rotation_degrees
			camera_rot.x = clamp(camera_rot.x, -70, 70)
			rotation_helper.rotation_degrees = camera_rot

func process_input(delta):

	# ----------------------------------
	# Walking
	dir = Vector3()
	var camera = $Rotation_Helper/Camera/camera
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
		is_sprinting = true
	else:
		is_sprinting = false
	# ----------------------------------
	
	# ----------------------------------
	# Crouching on/off
	if Input.is_action_just_pressed("crouch"):
		toggle_crouch()
	# ----------------------------------
	
	# ----------------------------------
	# Rotation via keyboard
	if Input.is_action_pressed("ui_up"):
		rot_x = -1
	elif Input.is_action_pressed("ui_down"):
		rot_x = 1
	elif Input.is_action_just_released("ui_up"):
		rot_x = 0
	elif Input.is_action_just_released("ui_down"):
		rot_x = 0

	if Input.is_action_pressed("ui_left"):
		rot_y = -1
	elif Input.is_action_pressed("ui_right"):
		rot_y = 1
	elif Input.is_action_just_released("ui_right"):
		rot_y = 0
	elif Input.is_action_just_released("ui_left"):
		rot_y = 0
	# ----------------------------------

func toggle_crouch():
	if $AnimationPlayer.is_playing():
		return
	var companions = game_params.get_companions()
	if is_crouching:
		$AnimationPlayer.play_backwards("crouch")
		for companion in companions:
			companion.stand_up()
	else:
		$AnimationPlayer.play("crouch")
		for companion in companions:
			companion.sit_down()
	is_crouching = not is_crouching
	var hud = get_hud()
	if hud:
		hud.set_crouch_indicator(is_crouching)

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
	if vel.x > 0.001 or vel.x < -0.001 or vel.z > 0.001 or vel.z < -0.001:
		if not $SoundWalking.is_playing():
			$SoundWalking.play()
		$SoundWalking.pitch_scale = 2 if is_sprinting else 1
	else:
		$SoundWalking.stop()
	vel = move_and_slide(vel, Vector3(0,1,0), true, 4, deg2rad(MAX_SLOPE_ANGLE), is_in_party())

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