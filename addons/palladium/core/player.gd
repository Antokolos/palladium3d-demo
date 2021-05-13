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
var angle_x_reset = false
var is_in_jump = false

func _ready():
	if is_player() or (
			initial_player \
			and not game_state.is_loading() \
			and not game_state.is_transition()
		):
			become_player()
	for enemy in get_tree().get_nodes_in_group("enemies"):
		enemy.connect("attack_started", self, "_on_enemy_attack_started")
		enemy.connect("attack_stopped", self, "_on_enemy_attack_stopped")
		enemy.connect("attack_finished", self, "_on_enemy_attack_finished")
	#activate() -- restored from save

func hit(injury_rate, hit_direction_node = null, hit_dir_vec = Z_DIR):
	.hit(injury_rate, hit_direction_node, hit_dir_vec)
	var health_new = game_state.player_health_current - injury_rate
	if health_new > 0:
		take_damage(false, hit_direction_node, hit_dir_vec)
	else:
		take_damage(true, hit_direction_node, hit_dir_vec)
	game_state.set_health(self, health_new, game_state.player_health_max)

func reset_movement():
	.reset_movement()
	input_movement_vector.x = 0
	input_movement_vector.y = 0

func reset_rotation():
	.reset_rotation()
	angle_rad_x = 0
	if rotation_helper:
		rotation_helper.set_rotation_degrees(Vector3(0, 0, 0))
	if upper_body_shape:
		upper_body_shape.set_rotation_degrees(Vector3(-90, 0, 0))

### Use target ###

func use(player_node, camera_node):
	var u = .use(player_node, camera_node)
	if not u:
		game_state.handle_conversation(player_node, self, player_node)
	return true

func add_highlight(player_node):
	var h = .add_highlight(player_node)
	return game_state.handle_player_highlight(player_node, self) if h.empty() else h

### States ###

func set_simple_mode(enable):
	get_model().set_simple_mode(enable)

func remove_item_from_hand():
	get_model().remove_item_from_hand()

func process_rotation(need_to_update_collisions):
	var result = .process_rotation(need_to_update_collisions)
	if angle_rad_x == 0:
		return { "rotate_x" : false, "rotate_y" : result.rotate_y }
	if need_to_update_collisions:
		move_and_collide(Vector3.ZERO)
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
	if angle_x_reset:
		angle_rad_x = 0
		angle_x_reset = false
	return { "rotate_x" : true, "rotate_y" : result.rotate_y }

func get_snap():
	return Vector3.ZERO if is_in_jump else Vector3.UP

func _on_character_dead(player):
	._on_character_dead(player)
	if equals(player):
		game_state.game_over()

func _on_enemy_attack_started(player_node, target):
	if is_player_controlled() or not is_in_party():
		return
	set_point_of_interest(player_node)

func _on_enemy_attack_stopped(player_node, target):
	if is_player_controlled() or not is_in_party():
		return
	clear_poi_if_it_is(player_node)

func _on_enemy_attack_finished(player_node, target, previous_target):
	if is_player_controlled() or not is_in_party():
		return
	clear_poi_if_it_is(player_node)

func is_joypad_look(event):
	if not event is InputEventJoypadMotion:
		return false
	var a = event.get_axis()
	return a == JOY_AXIS_2 or a == JOY_AXIS_3

func _input(event):
	if not is_player() or not is_activated():
		return
	var hud = game_state.get_hud()
	var conversation = hud.conversation
	if conversation.is_visible_in_tree():
		if story_node.can_choose():
			if event.is_action_pressed("dialogue_option_1"):
				conversation_manager.story_choose(self, 0)
			elif event.is_action_pressed("dialogue_option_2"):
				conversation_manager.story_choose(self, 1)
			elif event.is_action_pressed("dialogue_option_3"):
				conversation_manager.story_choose(self, 2)
			elif event.is_action_pressed("dialogue_option_4"):
				conversation_manager.story_choose(self, 3)
		elif event.is_action_pressed("dialogue_next"):
			conversation_manager.proceed_story_immediately(self)
	if is_in_party() and not cutscene_manager.is_cutscene():
		if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			angle_rad_x = deg2rad(event.relative.y * settings.get_sensitivity() * settings.get_yaxis_coeff())
			angle_rad_y = deg2rad(event.relative.x * settings.get_sensitivity() * -1)
			angle_x_reset = true
			angle_y_reset = true
			get_cam().process_rotation(self)
		elif is_joypad_look(event):
			var v = event.get_axis_value()
			var nonzero = v > AXIS_VALUE_THRESHOLD or v < -AXIS_VALUE_THRESHOLD
			if event.get_axis() == JOY_AXIS_2:  # Joypad Right Stick Horizontal Axis
				angle_rad_y = deg2rad(KEY_LOOK_SPEED_FACTOR * settings.get_sensitivity() * -v) if nonzero else 0
			if event.get_axis() == JOY_AXIS_3:  # Joypad Right Stick Vertical Axis
				angle_rad_x = deg2rad(KEY_LOOK_SPEED_FACTOR * settings.get_sensitivity() * v * settings.get_yaxis_coeff()) if nonzero else 0
		else:
			if event.is_action_pressed("movement_forward") \
				and input_movement_vector.y == 0:
				input_movement_vector.y = 1
			elif event.is_action_released("movement_forward") \
				and input_movement_vector.y == 1:
				input_movement_vector.y = 0
			elif event.is_action_pressed("movement_backward") \
				and input_movement_vector.y == 0:
				input_movement_vector.y = -1
			elif event.is_action_released("movement_backward") \
				and input_movement_vector.y == -1:
				input_movement_vector.y = 0
			
			if event.is_action_pressed("movement_left") \
				and input_movement_vector.x == 0:
				input_movement_vector.x = -1
			elif event.is_action_released("movement_left") \
				and input_movement_vector.x == -1:
				input_movement_vector.x = 0
			elif event.is_action_pressed("movement_right") \
				and input_movement_vector.x == 0:
				input_movement_vector.x = 1
			elif event.is_action_released("movement_right") \
				and input_movement_vector.x == 1:
				input_movement_vector.x = 0
			
			if event.is_action_pressed("cam_up"):
				angle_rad_x = deg2rad(KEY_LOOK_SPEED_FACTOR * settings.get_sensitivity() * -1 * settings.get_yaxis_coeff())
			elif event.is_action_pressed("cam_down"):
				angle_rad_x = deg2rad(KEY_LOOK_SPEED_FACTOR * settings.get_sensitivity() * settings.get_yaxis_coeff())
			elif event.is_action_released("cam_up") or event.is_action_released("cam_down"):
				angle_rad_x = 0
			
			if event.is_action_pressed("cam_left"):
				angle_rad_y = deg2rad(KEY_LOOK_SPEED_FACTOR * settings.get_sensitivity())
			elif event.is_action_pressed("cam_right"):
				angle_rad_y = deg2rad(KEY_LOOK_SPEED_FACTOR * settings.get_sensitivity() * -1)
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

func get_movement_data(is_player):
	if is_player \
		and is_in_party() \
		and input_movement_vector.length_squared() > 0 \
		and not is_movement_disabled() \
		and not cutscene_manager.is_cutscene():
			var dir_input = Vector3()
			var cam_xform = get_cam().get_global_transform()
			var n = input_movement_vector.normalized()
			dir_input += -cam_xform.basis.z.normalized() * n.y
			dir_input += cam_xform.basis.x.normalized() * n.x
			get_cam().walk_initiate(self)
			return PLDMovementData.new().with_dir(dir_input).with_rest_state(false)
	else:
		if is_player and not cutscene_manager.is_cutscene():
			get_cam().walk_stop(self)
		return .get_movement_data(is_player)

func _physics_process(delta):
	if not game_state.is_level_ready():
		character_nodes.stop_all()
		return
	var is_player = is_player()
	var d = .do_process(delta, is_player)
	if is_player and d.is_rotating:
		get_cam().process_rotation(self)
	if has_floor_collision() and is_in_jump:
		is_in_jump = false
		character_nodes.play_sound_falling_to_floor()
