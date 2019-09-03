extends KinematicBody

export var initial_player = false
export var name_hint = "player"
export var model_path = "res://scenes/female.tscn"

const GRAVITY = -6.2
var vel = Vector3()
const MAX_SPEED = 5
const JUMP_SPEED = 4.5
const ACCEL= 1.5

const MAX_SPRINT_SPEED = 15
const SPRINT_ACCEL = 4.5

var dir = Vector3()

const DEACCEL= 16
const MAX_SLOPE_ANGLE = 40

onready var body_shape = $Body_CollisionShape
onready var rotation_helper = $Rotation_Helper
onready var model = rotation_helper.get_node("Model")

var is_walking = false
var is_crouching = false
var is_sprinting = false

var rot_x = 0
var rot_y = 0

var MOUSE_SENSITIVITY = 0.1 #0.05
var KEY_LOOK_SPEED_FACTOR = 30

#####

export var floor_path = "../NavigationMeshInstance/floor_demo_full/floor_demo/StaticBodyFloor"
export var rotation_speed = 0.03
export var linear_speed = 2.8

onready var pyramid = get_node("/root/palladium")
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
	var player_position = get_node(game_params.player_path).get_global_transform().origin
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
	
	var model = get_node("Rotation_Helper/Model").get_child(0)
	if not path.empty():
		companion_state = COMPANION_STATE.WALK
		model.walk(rotation_angle_to_player_deg)
		if distance <= ALIGNMENT_RANGE:
			path.pop_front()
			dir = Vector3()
		else:
			dir = target_dir.normalized()
	elif distance > FOLLOW_RANGE:
		companion_state = COMPANION_STATE.WALK
		model.walk(rotation_angle_to_player_deg)
		dir = target_dir.normalized()
	elif distance > CLOSEUP_RANGE and companion_state == COMPANION_STATE.WALK:
		model.walk(rotation_angle_to_player_deg)
		dir = target_dir.normalized()
	else:
#		aggression_level = 0
		companion_state = COMPANION_STATE.REST
		model.look(rotation_angle_to_player_deg)
#		state.set_angular_velocity(zero_dir)
		dir = Vector3()

func get_navpath(pstart, pend):
	var p1 = pyramid.get_closest_point(pstart)
	var p2 = pyramid.get_closest_point(pend)
	var p = pyramid.get_simple_path(p1, p2, true)
	return Array(p) # Vector3array too complex to use, convert to regular array

func build_path():
	var current_transform = get_global_transform()
	var current_position = current_transform.origin
	var player_position = get_node(game_params.player_path).get_global_transform().origin
	var mov_vec = player_position - current_position
	mov_vec.y = 0
	if mov_vec.length() < CLOSEUP_RANGE - ALIGNMENT_RANGE:
		clear_path()
		return
	# filter out points of the path, distance to which is greater than distance to player
	while not path.empty():
		var pt = path.front()
		var mov_pt = player_position - pt
		if mov_pt.length() <= mov_vec.length():
			break
		path.pop_front()
	if is_on_wall() and path.empty(): # should check possible stuck
		#clear_path()
		path = get_navpath(get_global_transform().origin, get_node(game_params.player_path).get_global_transform().origin)
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
	return get_cam_holder().get_node("camera")

func use(player_node):
	var hud = player_node.get_hud()
	if conversation_manager.conversation_active():
		conversation_manager.stop_conversation(player_node)
	elif not hud.inventory.visible:
		conversation_manager.start_conversation(player_node, self, "Conversation")
	else: # hud.inventory.visible:
		var item = hud.get_active_item()
		if item and item.nam == "saffron_bun":
			hud.inventory.visible = false
			item.remove()
			conversation_manager.start_conversation(player_node, self, "Bun")

func get_model():
	return get_node("Rotation_Helper/Model").get_child(0)

func _unhandled_input(event):
	if not is_player():
		return
	var is_key = event is InputEventKey and event.is_pressed()
	if not is_key:
		return
	var hud = get_hud()
	var conversation = hud.get_node("Conversation")
	if conversation.is_visible_in_tree():
		var story = conversation.get_node('StoryNode')
		if conversation_manager.in_choice and event.scancode == KEY_1:
			conversation_manager.proceed_story_immediately(self)
		elif event.scancode >= KEY_1 and event.scancode <= KEY_9:
			conversation_manager.story_choose(self, event.scancode - KEY_1)

func add_highlight():
	#door_mesh.mesh.surface_set_material(surface_idx_door, null)
#	door_mesh.set_surface_material(surface_idx_door, outlined_material)
	return "E: Поговорить"

func remove_highlight():
#	door_mesh.set_surface_material(surface_idx_door, null)
	#door_mesh.mesh.surface_set_material(surface_idx_door, material)
	pass

#####

func is_player():
	return get_node(game_params.player_path) == self

func become_player():
	if is_player():
		return
	var player = get_node(game_params.player_path)
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
	player_rotation_helper.set_rotation_degrees(Vector3(0, 0, 0))
	game_params.companion_path = game_params.player_path
	game_params.player_path = get_path()

func _ready():
	exclusions.append(self)
	exclusions.append(get_node(floor_path))
	exclusions.append($Body_CollisionShape)  # looks like it is not included, but to be sure...
	exclusions.append($Feet_CollisionShape)
	if initial_player:
		var hud_container = get_hud_holder()
		hud_container.add_child(load("res://hud.tscn").instance())
		var camera_container = get_node("Rotation_Helper/Camera")
		camera_container.add_child(load("res://camera.tscn").instance())
	var model_container = get_node("Rotation_Helper/Model")
	for ch in model_container.get_children():
		ch.queue_free()
	var model = load(model_path).instance()
	model.set_simple_mode(initial_player)
	model_container.add_child(model)

func _physics_process(delta):
	if is_player():
		process_input(delta)
	else:
		var player = get_node(game_params.player_path)
		if not player:
			return
		var current_transform = get_global_transform()
		var current_position = current_transform.origin
		var player_position = player.get_global_transform().origin
		build_path()
		var target_position = path.front() if path.size() > 0 else player_position
		follow(current_transform, target_position)
	
	process_movement(delta)
	if rot_x != 0:
		rotation_helper.rotate_x(deg2rad(rot_x * KEY_LOOK_SPEED_FACTOR * MOUSE_SENSITIVITY))
	if rot_y != 0:
		self.rotate_y(deg2rad(rot_y * KEY_LOOK_SPEED_FACTOR * MOUSE_SENSITIVITY * -1))

func _input(event):
	if is_player():
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
	if is_crouching:
		$AnimationPlayer.play_backwards("crouch")
	else:
		$AnimationPlayer.play("crouch")
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
	vel = move_and_slide(vel,Vector3(0,1,0), 0.05, 4, deg2rad(MAX_SLOPE_ANGLE))

func take(nam, model_path):
	var hud = get_hud()
	if hud:
		hud.take(nam, model_path)

func shadow_casting_enable(enable):
	common_utils.shadow_casting_enable(self, enable)