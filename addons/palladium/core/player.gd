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

var input_movement_vector = Vector2()
var angle_rad_x = 0
var is_in_jump = false

func _ready():
	if initial_player:
		var camera = load("res://addons/palladium/core/camera.tscn").instance()
		get_cam_holder().add_child(camera)
		camera.rebuild_exceptions(self)
		game_state.set_player_name_hint(get_name_hint())
	get_model().set_simple_mode(initial_player)
	activate()

func reset_movement():
	.reset_movement()
	input_movement_vector.x = 0
	input_movement_vector.y = 0

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

func use(player_node, camera_node):
	if not conversation_manager.conversation_is_in_progress():
		game_state.handle_conversation(player_node, self, player_node)

func add_highlight(player_node):
	var hud = game_state.get_hud()
	var inventory = hud.inventory
	var conversation = hud.conversation
	if conversation.visible:
		return ""
	return game_state.handle_player_highlight(player_node, self)

### States ###

func set_simple_mode(enable):
	get_model().set_simple_mode(enable)

func remove_item_from_hand():
	get_model().remove_item_from_hand()

func join_party():
	game_state.join_party(get_name_hint())

func leave_party():
	game_state.leave_party(get_name_hint())

func become_player():
	if is_player():
		get_cam().rebuild_exceptions(self)
		return
	var player = game_state.get_player()
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
	game_state.set_player_name_hint(get_name_hint())
	game_state.set_underwater(self, game_state.is_underwater(get_name_hint()))
	game_state.set_poisoned(self, game_state.is_poisoned(get_name_hint()))
	camera.rebuild_exceptions(self)

func process_rotation(need_to_update_collisions):
	var result = .process_rotation(need_to_update_collisions)
	if angle_rad_x == 0:
		return result
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
	angle_rad_x = 0
	return true

func get_snap():
	return ZERO_DIR if is_in_jump else UP_DIR

func _input(event):
	if not is_player():
		return
	var hud = game_state.get_hud()
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
		elif event is InputEventJoypadMotion:
			var v = event.get_axis_value()
			var nonzero = v > AXIS_VALUE_THRESHOLD or v < -AXIS_VALUE_THRESHOLD
			if event.get_axis() == JOY_AXIS_2:  # Joypad Right Stick Horizontal Axis
				angle_rad_y = deg2rad(KEY_LOOK_SPEED_FACTOR * MOUSE_SENSITIVITY * -v) if nonzero else 0
			if event.get_axis() == JOY_AXIS_3:  # Joypad Right Stick Vertical Axis
				angle_rad_x = deg2rad(KEY_LOOK_SPEED_FACTOR * MOUSE_SENSITIVITY * v) if nonzero else 0
		else:
			if event.is_action_pressed("movement_forward") \
				or event.is_action_released("movement_backward"):
				input_movement_vector.y += 1
			elif event.is_action_pressed("movement_backward") \
				or event.is_action_released("movement_forward"):
				input_movement_vector.y -= 1
			
			if event.is_action_pressed("movement_left") \
				or event.is_action_released("movement_right"):
				input_movement_vector.x -= 1
			elif event.is_action_pressed("movement_right") \
				or event.is_action_released("movement_left"):
				input_movement_vector.x += 1
			
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
			
			if event.is_action_pressed("crouch"):
				toggle_crouch()
				set_sprinting(false)
			elif can_jump() and event.is_action_pressed("movement_jump"):
				vel.y = JUMP_SPEED
				is_in_jump = true
			elif not is_crouching():
				if event.is_action_pressed("movement_sprint"):
					set_sprinting(true)
				elif event.is_action_released("movement_sprint"):
					set_sprinting(false)

func get_movement_data(in_party, is_player):
	if is_player \
		and in_party \
		and input_movement_vector.length_squared() > 0 \
		and not is_movement_disabled() \
		and not cutscene_manager.is_cutscene():
			var dir_input = Vector3()
			var cam_xform = get_cam().get_global_transform()
			var n = input_movement_vector.normalized()
			dir_input += -cam_xform.basis.z.normalized() * n.y
			dir_input += cam_xform.basis.x.normalized() * n.x
			return PLDMovementData.new().with_dir(dir_input).with_rest_state(false)
	else:
		return .get_movement_data(in_party, is_player)

func _physics_process(delta):
	if not is_activated():
		return
	var in_party = is_in_party()
	var is_player = is_player()
	.do_process(delta, in_party, is_player)
	if has_floor_collision() and is_in_jump:
		is_in_jump = false
		$SoundFallingToFloor.play()
