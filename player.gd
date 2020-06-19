extends PLDCharacter
class_name PLDPlayer

const CAMERA_ROT_MIN_DEG = -88
const CAMERA_ROT_MAX_DEG = 88
const MODEL_ROT_MIN_DEG = -88
const MODEL_ROT_MAX_DEG = 0
const SHAPE_ROT_MIN_DEG = -90-88
const SHAPE_ROT_MAX_DEG = -90+88

export var initial_player = true

onready var upper_body_shape = $UpperBody_CollisionShape
onready var rotation_helper = $Rotation_Helper

var angle_rad_x = 0
var is_in_jump = false

func _ready():
	if initial_player:
		var camera = load("res://camera.tscn").instance()
		get_cam_holder().add_child(camera)
		camera.rebuild_exceptions(self)
		game_params.set_player_name_hint(get_name_hint())
	get_model().set_simple_mode(initial_player)

func reset_rotation():
	.reset_rotation()
	angle_rad_x = 0
	rotation_helper.set_rotation_degrees(Vector3(0, 0, 0))
	upper_body_shape.set_rotation_degrees(Vector3(-90, 0, 0))


### Getting character's parts ###

func get_cam_holder():
	return get_node("Rotation_Helper/Camera")

func get_cam():
	var cutscene_cam = cutscene_manager.get_cam()
	return cutscene_cam if cutscene_cam else get_cam_holder().get_node("camera")

### Use target ###

func add_highlight(player_node):
	var hud = game_params.get_hud()
	var inventory = hud.inventory
	var conversation = hud.conversation
	if conversation.visible:
		return ""
	return game_params.handle_player_highlight(player_node, self)

func remove_highlight(player_node):
	pass

func use(player_node):
	if not conversation_manager.conversation_is_in_progress():
		game_params.handle_conversation(player_node, self, player_node)

### States ###

func set_simple_mode(enable):
	get_model().set_simple_mode(enable)

func remove_item_from_hand():
	get_model().remove_item_from_hand()

func join_party():
	game_params.join_party(get_name_hint())

func leave_party():
	game_params.leave_party(get_name_hint())

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
	game_params.set_player_name_hint(get_name_hint())
	camera.rebuild_exceptions(self)

func process_input(delta):

	# ----------------------------------
	# Walking
	var dir = Vector3()
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

	dir += -cam_xform.basis.z.normalized() * input_movement_vector.y
	dir += cam_xform.basis.x.normalized() * input_movement_vector.x
	# ----------------------------------

	# ----------------------------------
	# Crouching on/off
	if Input.is_action_just_pressed("crouch"):
		toggle_crouch()
	# ----------------------------------

	# ----------------------------------
	# Jumping
	if is_on_floor():
		if Input.is_action_just_pressed("movement_jump"):
			vel.y = JUMP_SPEED
			is_in_jump = true
	# ----------------------------------

	if is_crouching():
		return dir

	# ----------------------------------
	# Sprinting
	if Input.is_action_pressed("movement_sprint"):
		set_sprinting(true)
	else:
		set_sprinting(false)
	# ----------------------------------
	return dir

func process_rotation(need_to_update_collisions):
	var result = .process_rotation(need_to_update_collisions)
	if angle_rad_x != 0:
		rotation_helper.rotate_x(angle_rad_x)
		get_model_holder().rotate_x(angle_rad_x)
		upper_body_shape.rotate_x(angle_rad_x)
		var camera_rot = rotation_helper.rotation_degrees
		var model_rot = Vector3(camera_rot.x, camera_rot.y, camera_rot.z)
		var shape_rot = upper_body_shape.rotation_degrees
		camera_rot.x = clamp(camera_rot.x, CAMERA_ROT_MIN_DEG, CAMERA_ROT_MAX_DEG)
		rotation_helper.rotation_degrees = camera_rot
		model_rot.x = clamp(model_rot.x, MODEL_ROT_MIN_DEG, MODEL_ROT_MAX_DEG)
		get_model_holder().rotation_degrees = model_rot
		shape_rot.x = clamp(shape_rot.x, SHAPE_ROT_MIN_DEG, SHAPE_ROT_MAX_DEG)
		upper_body_shape.rotation_degrees = shape_rot
		return true
	return result

func get_snap():
	return ZERO_DIR if is_in_jump else UP_DIR

func _input(event):
	if not is_player():
		return
	var hud = game_params.get_hud()
	var conversation = hud.conversation
	if conversation.is_visible_in_tree():
		if event.is_action_pressed("dialogue_next"):
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
			process_rotation(true)
			angle_rad_x = 0
			angle_rad_y = 0
		elif event is InputEventJoypadMotion:
			var v = event.get_axis_value()
			var nonzero = v > AXIS_VALUE_THRESHOLD or v < -AXIS_VALUE_THRESHOLD
			if event.get_axis() == JOY_AXIS_2:  # Joypad Right Stick Horizontal Axis
				angle_rad_y = deg2rad(KEY_LOOK_SPEED_FACTOR * MOUSE_SENSITIVITY * -v) if nonzero else 0
			if event.get_axis() == JOY_AXIS_3:  # Joypad Right Stick Vertical Axis
				angle_rad_x = deg2rad(KEY_LOOK_SPEED_FACTOR * MOUSE_SENSITIVITY * v) if nonzero else 0
		else:
			if event.is_action_pressed("cam_up"):
				angle_rad_x = deg2rad(KEY_LOOK_SPEED_FACTOR * MOUSE_SENSITIVITY * -1)
			elif event.is_action_pressed("cam_down"):
				angle_rad_x = deg2rad(KEY_LOOK_SPEED_FACTOR * MOUSE_SENSITIVITY)
			elif event.is_action_released("cam_up") or event.is_action_released("cam_down"):
				angle_rad_x = 0
			
			if event.is_action_pressed("cam_left"):
				angle_rad_y = deg2rad(KEY_LOOK_SPEED_FACTOR * MOUSE_SENSITIVITY)
			elif event.is_action_pressed("cam_right"):
				angle_rad_y = deg2rad(KEY_LOOK_SPEED_FACTOR * MOUSE_SENSITIVITY * -1)
			elif event.is_action_released("cam_left") or event.is_action_released("cam_right"):
				angle_rad_y = 0

func _physics_process(delta):
	if is_on_floor() and is_in_jump:
		is_in_jump = false
		$SoundFallingToFloor.play()
	if is_player() and is_in_party() and not is_cutscene() and not cutscene_manager.is_cutscene():
		set_dir(process_input(delta))
