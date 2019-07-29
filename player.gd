extends KinematicBody

export var giprobe_path = "../GIProbe" 

const GRAVITY = -6.2
var vel = Vector3()
const MAX_SPEED = 5
const JUMP_SPEED = 4.5
const ACCEL= 1.5

const MAX_SPRINT_SPEED = 15
const SPRINT_ACCEL = 4.5
var is_sprinting = false

onready var flashlight = $Rotation_Helper/Camera/Flashlight
onready var hints = get_node("HUD/Hints")
onready var inventory = get_node("HUD/Inventory")
onready var inventory_panel = inventory.get_node("HBoxContainer")
onready var dimmer = get_node("HUD/Dimmer")
onready var tablet = get_node("HUD/tablet")
onready var use_point = get_node("Rotation_Helper/Camera/Gun_Fire_Points/Use_Point")
onready var giprobe = get_node(giprobe_path)

var dir = Vector3()

const DEACCEL= 16
const MAX_SLOPE_ANGLE = 40

onready var camera = $Rotation_Helper/Camera
onready var env_norm = preload("res://env_norm.tres")
onready var env_opt = preload("res://env_opt.tres")
onready var env_good = preload("res://env_good.tres")
onready var env_high = preload("res://env_high.tres")

onready var body_shape = $Body_CollisionShape
onready var rotation_helper = $Rotation_Helper
onready var model = rotation_helper.get_node("Model")
var crouch = false
onready var indicator_crouch = get_node("HUD/Indicators/Indicators_border/IndicatorCrouch")
onready var tex_crouch_off = preload("res://assets/ui/tex_crouch_off.tres")
onready var tex_crouch_on = preload("res://assets/ui/tex_crouch_on.tres")

onready var culling_rays = get_node("Rotation_Helper/Camera/culling_rays")

var rot_x = 0
var rot_y = 0

var MOUSE_SENSITIVITY = 0.1 #0.05
var KEY_LOOK_SPEED_FACTOR = 30

var active_item_idx = -1

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	change_quality(settings.quality)
	var dialog = $QuitDialog
	dialog.get_ok().text = "Yes"
	dialog.get_cancel().text = "No"
	use_point.player_node = self
	get_tree().set_auto_accept_quit(false)

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			dimmer.visible = true
		get_tree().paused = true
		$QuitDialog.popup_centered()

func change_culling():
	camera.far = culling_rays.get_max_distance(camera.get_global_transform().origin)

func _physics_process(delta):
	process_input(delta)
	process_movement(delta)
	if rot_x != 0:
		rotation_helper.rotate_x(deg2rad(rot_x * KEY_LOOK_SPEED_FACTOR * MOUSE_SENSITIVITY))
	if rot_y != 0:
		self.rotate_y(deg2rad(rot_y * KEY_LOOK_SPEED_FACTOR * MOUSE_SENSITIVITY * -1))
	use_point.highlight()
	change_culling()

func change_quality(quality):
	match quality:
		settings.QUALITY_NORM:
			camera.environment = env_norm
			if giprobe:
				giprobe.visible = false
			get_tree().call_group("fire_sources", "set_quality_normal")
			get_tree().call_group("light_sources", "enable", false)
			get_tree().call_group("light_sources", "shadow_enable", false)
			flashlight.set("shadow_enabled", false)
			ProjectSettings.set_setting("rendering/quality/voxel_cone_tracing/high_quality", false)
		settings.QUALITY_OPT:
			camera.environment = env_opt
			if giprobe:
				giprobe.visible = false
			get_tree().call_group("fire_sources", "set_quality_optimal")
			get_tree().call_group("light_sources", "enable", false)
			get_tree().call_group("light_sources", "shadow_enable", false)
			flashlight.set("shadow_enabled", false)
			ProjectSettings.set_setting("rendering/quality/voxel_cone_tracing/high_quality", false)
		settings.QUALITY_GOOD:
			camera.environment = env_good
			if giprobe:
				giprobe.visible = true
			get_tree().call_group("fire_sources", "set_quality_good")
			get_tree().call_group("light_sources", "enable", true)
			get_tree().call_group("light_sources", "shadow_enable", false)
			flashlight.set("shadow_enabled", false)
			ProjectSettings.set_setting("rendering/quality/voxel_cone_tracing/high_quality", false)
		settings.QUALITY_HIGH:
			camera.environment = env_high
			if giprobe:
				giprobe.visible = true
			get_tree().call_group("fire_sources", "set_quality_high")
			get_tree().call_group("light_sources", "enable", true)
			get_tree().call_group("light_sources", "shadow_enable", true)
			flashlight.set("shadow_enabled", true)
			ProjectSettings.set_setting("rendering/quality/voxel_cone_tracing/high_quality", true)
	get_node("Rotation_Helper/Camera/viewpoint/shader_cache").refresh()

func process_input(delta):

	# ----------------------------------
	# Walking
	dir = Vector3()
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
	# Turning the flashlight on/off
	if Input.is_action_just_pressed("flashlight"):
		if flashlight.is_visible_in_tree():
			flashlight.hide()
		else:
			flashlight.show()
	# ----------------------------------
	
	# ----------------------------------
	# Crouching on/off
	if Input.is_action_just_pressed("crouch"):
		toggle_crouch()
	# ----------------------------------
	
	# ----------------------------------
	# Inventory on/off
	if Input.is_action_just_pressed("ui_focus_next") and not conversation_manager.conversation_active:
		active_item_idx = -1
		if inventory.visible:
			inventory.visible = false
			hints.visible = true
		else:
			inventory.visible = true
			hints.visible = false
			var items = inventory_panel.get_children()
			var idx = 0
			for item in items:
				items[idx].get_node("LabelKey").text = "F" + str(idx + 1)
				idx = idx + 1
	# ----------------------------------
	
	# ----------------------------------
	# Capturing/Freeing the cursor
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			show_tablet(false)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			show_tablet(true)
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
	if crouch:
		$AnimationPlayer.play_backwards("crouch")
	else:
		$AnimationPlayer.play("crouch")
	# Code below can be used to toggle crouching without animations
	#var hdiff = -1.0 if crouch else 1.0
	#body_shape.shape.height = body_shape.shape.height - hdiff
	#body_shape.translation = body_shape.translation + Vector3(0, -hdiff/2.0, 0)
	#rotation_helper.translation = rotation_helper.translation + Vector3(0, -hdiff, 0)
	#model.translation = model.translation + Vector3(0, hdiff, 0)
	crouch = not crouch
	if crouch:
		indicator_crouch.set("custom_styles/panel", tex_crouch_on)
	else:
		indicator_crouch.set("custom_styles/panel", tex_crouch_off)

func show_tablet(is_show):
	if is_show:
		dimmer.visible = true
		tablet.visible = true
		get_tree().paused = true
	else:
		get_tree().paused = false
		tablet.visible = false
		dimmer.visible = false
		settings.save_settings()

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
	if event.is_action_pressed("action"):
		use_point.action()

func take(nam, model_path):
	var item = load("res://item.tscn").instance()
	item.nam = nam
	item.model_path = model_path
	var image_file = "res://assets/items/%s.png" % nam
	var image = load(image_file)
	var texture = ImageTexture.new()
	texture.create_from_image(image)
	item.get_node("TextureRect").texture = texture
	item.get_node("LabelDesc").text = tr(nam)
	inventory_panel.add_child(item)

func get_active_item():
	return inventory_panel.get_child(active_item_idx) if active_item_idx >= 0 else null

func _unhandled_input(event):
	if inventory.is_visible_in_tree() and event is InputEventKey and event.is_pressed():
		if event.scancode < KEY_F1 or event.scancode > KEY_F9:
			return
		active_item_idx = -1
		var items = inventory_panel.get_children()
		if items.empty():
			return
		var idx = 0
		var target_idx = event.scancode - KEY_F1
		for item in items:
			var label_key = items[idx].get_node("LabelKey")
			if idx == target_idx:
				label_key.set("custom_colors/font_color", Color(1, 0, 0))
				active_item_idx = idx
			else:
				label_key.set("custom_colors/font_color", Color(1, 1, 1))
			idx = idx + 1

func _on_QuitDialog_confirmed():
	get_tree().quit()

func _on_QuitDialog_popup_hide():
	if not tablet.visible:
		get_tree().paused = false
		dimmer.visible = false
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)