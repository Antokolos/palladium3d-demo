extends KinematicBody

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

func _physics_process(delta):
	process_input(delta)
	process_movement(delta)
	if rot_x != 0:
		rotation_helper.rotate_x(deg2rad(rot_x * KEY_LOOK_SPEED_FACTOR * MOUSE_SENSITIVITY))
	if rot_y != 0:
		self.rotate_y(deg2rad(rot_y * KEY_LOOK_SPEED_FACTOR * MOUSE_SENSITIVITY * -1))

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
	var hud = get_node("HUD/hud")
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

func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotation_helper.rotate_x(deg2rad(event.relative.y * MOUSE_SENSITIVITY))
		self.rotate_y(deg2rad(event.relative.x * MOUSE_SENSITIVITY * -1))

		var camera_rot = rotation_helper.rotation_degrees
		camera_rot.x = clamp(camera_rot.x, -70, 70)
		rotation_helper.rotation_degrees = camera_rot

func take(nam, model_path):
	var hud = get_node("HUD/hud")
	if hud:
		hud.take(nam, model_path)

func shadow_casting_enable(enable):
	common_utils.shadow_casting_enable(self, enable)