extends PLDPathfinder
class_name PLDCharacter

signal visibility_to_player_changed(player_node, previous_state, new_state)
signal patrolling_changed(player_node, previous_state, new_state)
signal aggressive_changed(player_node, previous_state, new_state)
signal attack_started(player_node, target)
signal take_damage(player_node, fatal, hit_direction_node)

const GRAVITY_DEFAULT = 6.2
const GRAVITY_UNDERWATER = 0.2
const MAX_SPEED = 3
const MAX_SPRINT_SPEED = 10
const JUMP_SPEED = 4.5
const DIVE_SPEED = 0.2
const BOB_UP_SPEED = 1.5
const ACCEL= 1.5
const DEACCEL= 16
const SPRINT_ACCEL = 4.5
const MIN_MOVEMENT = 0.01
const SPRINTING_DISTANCE_THRESHOLD = 10

const PUSH_STRENGTH = 10
const PUSH_BACK_STRENGTH = 30
const NONCHAR_PUSH_STRENGTH = 2
const NONCHAR_COLLISION_RANGE_MAX = 5.9

const MAX_SLOPE_ANGLE_RAD = deg2rad(60)
const AXIS_VALUE_THRESHOLD = 0.15

export var has_ranged_attack = false
export var has_melee_attack = false

onready var character_nodes = $character_nodes

var vel = Vector3()

var is_hidden = false
var is_patrolling = false
var is_aggressive = false
var is_crouching = false
var is_sprinting = false
var is_underwater = false
var is_poisoned = false
var relationship = 0
var morale = 0
var stuns_count = 0
var has_floor_collision = true
var last_attack_target = null

func _ready():
	var model = get_model()
	game_state.connect("player_underwater", self, "_on_player_underwater")
	game_state.connect("player_poisoned", self, "_on_player_poisoned")
	model.connect("character_dead", self, "_on_character_dead")
	model.connect("character_dying", self, "_on_character_dying")
	game_state.register_player(self)

func get_gravity():
	return GRAVITY_UNDERWATER if is_underwater else GRAVITY_DEFAULT

func set_sound_walk(mode):
	character_nodes.set_sound_walk(mode)

func set_sound_attack(mode):
	character_nodes.set_sound_attack(mode)

func set_sound_miss(mode):
	character_nodes.set_sound_miss(mode)

func has_ranged_attack():
	return has_ranged_attack

func has_melee_attack():
	return has_melee_attack

func handle_attack():
	var possible_attack_target = character_nodes.get_possible_attack_target(false)
	if possible_attack_target:
		attack_start(possible_attack_target)
	else:
		stop_attack()

func attack_start(possible_attack_target, attack_anim_idx = -1):
	if not is_attacking():
		set_sprinting(false)
		set_last_attack_target(possible_attack_target)
		emit_signal("attack_started", self, possible_attack_target)
		set_point_of_interest(possible_attack_target)
		get_model().attack(attack_anim_idx)
		character_nodes.attack_start()

func stop_attack():
	if is_attacking():
		stop_cutscene()
		character_nodes.stop_attack()
		clear_point_of_interest()
		last_attack_target = null

func set_last_attack_target(last_attack_target):
	self.last_attack_target = last_attack_target

func get_last_attack_target():
	return last_attack_target

func is_attacking():
	return character_nodes.is_attacking() or get_model().is_attacking()

func hit(hit_direction_node):
	pass

func miss(hit_direction_node):
	pass

func take_damage(fatal, hit_direction_node):
	if not is_activated() or is_dying():
		return
	emit_signal("take_damage", self, fatal, hit_direction_node)
	stop_cutscene()
	get_model().take_damage(fatal)
	push_back(get_push_vec(hit_direction_node))
	if fatal:
		$Body_CollisionShape.disabled = true
		$Feet_CollisionShape.disabled = false
		character_nodes.enable_areas(false)

### Use target ###

func use(player_node, camera_node):
	var hud = game_state.get_hud()
	if hud and hud.get_active_item():
		var item = hud.get_active_item()
		if not item_is_weapon(item):
			return false
		hud.inventory.visible = false
		item.used(player_node, self)
		character_nodes.use_weapon(item)
		return true
	return false

func item_is_weapon(item):
	if not item:
		return false
	return DB.is_weapon_stun(item.item_id)

func add_highlight(player_node):
	var hud = game_state.get_hud()
	if hud and hud.get_active_item():
		var item = hud.get_active_item()
		if item_is_weapon(item):
			return "E: " + tr("ACTION_ATTACK")
	return ""

### Getting character's parts ###

func get_model_holder():
	return get_node("Model")

func get_model():
	return get_model_holder().get_child(0)

### States ###

func is_underwater():
	return is_underwater

func set_underwater(enable):
	is_underwater = enable
	vel.y = -DIVE_SPEED if enable or vel.y <= 0.0 else BOB_UP_SPEED
	character_nodes.set_underwater(enable)

func _on_player_underwater(player, enable):
	if player and not equals(player):
		return
	set_underwater(enable)

func is_poisoned():
	return is_poisoned

func set_poisoned(enable):
	is_poisoned = enable

func _on_player_poisoned(player, enable):
	if player and not equals(player):
		return
	set_poisoned(enable)

func activate():
	.activate()
	get_model().activate()
	enable_rays_to_characters(true)

func deactivate():
	.deactivate()
	enable_rays_to_characters(false)

func is_visible_to_player():
	return character_nodes.is_visible_to_player()

func is_hidden():
	return is_hidden

func set_hidden(enable):
	is_hidden = enable
	visible = not enable
	if has_node("UpperBody_CollisionShape"):
		$UpperBody_CollisionShape.disabled = enable
	$Body_CollisionShape.disabled = enable
	character_nodes.enable_areas(not enable)
	var is_player = is_player()
	if is_player:
		var companions = game_state.get_companions()
		for companion in companions:
			companion.set_hidden(enable)

func is_patrolling():
	return is_patrolling

func set_patrolling(enable):
	var is_patrolling_prev = is_patrolling
	is_patrolling = enable
	if is_patrolling_prev != is_patrolling:
		emit_signal("patrolling_changed", self, is_patrolling_prev, is_patrolling)
	if enable:
		set_aggressive(false)

func is_aggressive():
	return is_aggressive

func set_aggressive(enable):
	var is_aggressive_prev = is_aggressive
	is_aggressive = enable
	if is_aggressive_prev != is_aggressive:
		emit_signal("aggressive_changed", self, is_aggressive_prev, is_aggressive)
	if enable:
		set_patrolling(false)

func set_target_node(node, update_navpath = true):
	.set_target_node(node, update_navpath)
	if not node or is_player_controlled():
		return
	var cp = get_global_transform().origin
	var tp = node.get_global_transform().origin
	set_sprinting(cp.distance_to(tp) > SPRINTING_DISTANCE_THRESHOLD)

func rest():
	get_model().look()

func set_look_transition(force = false):
	if force \
		or conversation_manager.meeting_is_in_progress(name_hint, CHARS.PLAYER_NAME_HINT) \
		or conversation_manager.meeting_is_finished(name_hint, CHARS.PLAYER_NAME_HINT):
		get_model().set_look_transition(PLDCharacterModel.LOOK_TRANSITION_SQUATTING if is_crouching else PLDCharacterModel.LOOK_TRANSITION_STANDING)

func play_cutscene(cutscene_id):
	get_model().play_cutscene(cutscene_id)
	character_nodes.start_cutscene_timer()

func stop_cutscene():
	get_model().stop_cutscene()

func is_dying():
	return get_model().is_dying()

func is_dead():
	return get_model().is_dead()

func is_taking_damage():
	return get_model().is_taking_damage()

func is_movement_disabled():
	return get_model().is_movement_disabled()

func is_player_controlled():
	return is_in_party() and is_player() and not cutscene_manager.is_cutscene()

func sit_down():
	if not character_nodes.sit_down():
		return
	get_model().sit_down()
	var is_player = is_player()
	if is_player:
		var companions = game_state.get_companions()
		for companion in companions:
			companion.sit_down()
	is_sprinting = false
	is_crouching = true
	if is_player:
		var hud = game_state.get_hud()
		if hud:
			hud.set_crouch_indicator(true)

func stand_up():
	if not character_nodes.stand_up():
		return
	get_model().stand_up()
	var is_player = is_player()
	if is_player:
		var companions = game_state.get_companions()
		for companion in companions:
			companion.stand_up()
	is_crouching = false
	if is_player:
		var hud = game_state.get_hud()
		if hud:
			hud.set_crouch_indicator(false)

func is_crouching():
	return is_crouching

func toggle_crouch():
	stand_up() if is_crouching else sit_down()

func get_possible_attacker():
	return null

func can_run():
	return true

func is_sprinting():
	return is_sprinting

func set_sprinting(enable):
	if enable and not can_run():
		return
	is_sprinting = enable
	var is_player = is_player()
	if is_player:
		var companions = game_state.get_companions()
		for companion in companions:
			companion.set_sprinting(enable)

func get_relationship():
	return relationship

func set_relationship(relationship):
	self.relationship = relationship

func get_morale():
	return morale

func set_morale(morale):
	self.morale = morale

func get_stuns_count():
	return stuns_count

func set_stuns_count(stuns_count):
	self.stuns_count = stuns_count

func inc_stuns_count():
	stuns_count = stuns_count + 1

### Player/target following ###

func reset_movement():
	.reset_movement()
	vel.x = 0
	vel.y = 0
	vel.z = 0
	set_sprinting(false)

func reset_rotation():
	.reset_rotation()
	get_model_holder().set_rotation_degrees(Vector3(0, 0, 0))

func process_rotation(need_to_update_collisions):
	if angle_rad_y == 0 or is_dying():
		return false
	self.rotate_y(angle_rad_y)
	angle_rad_y = 0
	return true

func invoke_physics_pass():
	has_floor_collision = false
	vel = move_and_slide_with_snap(
		vel,
		get_snap(),
		Vector3.UP,
		true,
		4,
		MAX_SLOPE_ANGLE_RAD,
		is_in_party()
	)

func get_snap():
	return Vector3.UP

func is_need_to_use_physics(characters):
	if not is_visible_to_player():
		return false
	if is_player_controlled() or not has_floor_collision():
		return true
	for character in characters:
		if equals(character):
			continue
		if get_distance_to_character(character) < POINT_BLANK_RANGE:
			return true
	return false

func move_without_physics(hvel, delta):
	if hvel.length() >= MIN_MOVEMENT:
		global_translate(hvel * delta)
	return hvel

func process_movement(delta, dir, characters):
	var target = Vector3.ZERO if is_movement_disabled() else dir
	var is_need_to_use_physics = is_need_to_use_physics(characters)
	if is_need_to_use_physics:
		target.y = 0
	target = target.normalized()

	vel.y -= delta * get_gravity()

	if is_sprinting:
		target *= MAX_SPRINT_SPEED
	else:
		target *= MAX_SPEED

	var hvel = vel
	hvel.y = 0 if is_need_to_use_physics else target.y
	
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
	
	if is_need_to_use_physics:
		if vel.y <= 0.0 and hvel.length() < MIN_MOVEMENT and has_floor_collision():
			return { "is_walking" : false, "collides_floor" : true }
		vel = move_and_slide_with_snap(
			vel,
			get_snap(),
			Vector3.UP,
			true,
			4,
			MAX_SLOPE_ANGLE_RAD,
			is_in_party()
		)
	else:
		vel = move_without_physics(hvel, delta)
		return { "is_walking" : vel.length() >= MIN_MOVEMENT, "collides_floor" : has_floor_collision() }
	
	var is_walking = vel.length() >= MIN_MOVEMENT
	
	var sc = get_slide_count()
	var character_collisions = []
	var nonchar_collision = null
	var collides_floor = false
	for i in range(0, sc):
		var collision = get_slide_collision(i)
		var has_char_collision = false
		for character in characters:
			if collision.collider_id == character.get_instance_id():
				has_char_collision = true
				character_collisions.append(collision)
				break
		var is_floor_collision = collision.collider.get_collision_mask_bit(2) and collision.normal and collision.normal.y > 0
		collides_floor = collides_floor or is_floor_collision
		if not has_char_collision and not is_floor_collision:
			nonchar_collision = collision
	for collision in character_collisions:
		var character = collision.collider
		if not character.is_movement_disabled() and not character.is_player_controlled():
			character.vel = get_out_vec(-collision.normal) * PUSH_STRENGTH
			character.vel.y = 0
			character.invoke_physics_pass()

	if nonchar_collision and pathfinding_enabled and not is_player_controlled():
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
	return { "is_walking" : is_walking, "collides_floor" : collides_floor }

func get_out_vec(normal):
	var n = normal
	n.y = 0
	var cross = Vector3.UP.cross(n)
	var coeff = rand_range(-NONCHAR_COLLISION_RANGE_MAX, NONCHAR_COLLISION_RANGE_MAX)
	return (n + coeff * cross).normalized()

func get_push_vec(direction_node):
	if not direction_node:
		return Vector3.ZERO
	var dir_z = direction_node.get_global_transform().basis.z.normalized()
	dir_z.y = 0
	return -dir_z * PUSH_BACK_STRENGTH

func push_back(push_vec):
	vel = push_vec

func has_floor_collision():
	return has_floor_collision or is_on_floor()

func can_jump():
	return has_floor_collision() or is_underwater()

func get_rays_to_characters_pos():
	return character_nodes.get_rays_to_characters_pos()

func add_ray_to_character(another_character):
	return character_nodes.add_ray_to_character(another_character)

func update_ray_to_character(another_character, ray = null):
	return character_nodes.update_ray_to_character(another_character, ray)

func has_obstacles_between(another_character):
	return character_nodes.has_obstacles_between(another_character)

func enable_rays_to_character(another_character, enable):
	return character_nodes.enable_rays_to_character(another_character, enable)

func enable_rays_to_characters(enable):
	var characters = game_state.get_characters()
	for character in characters:
		enable_rays_to_character(character, enable)
		character.enable_rays_to_character(self, enable)

func do_process(delta, is_player):
	var d = { "is_moving" : false, "is_rotating" : false }
	var poi = get_point_of_interest()
	if not poi and (not is_activated() or is_movement_disabled()):
		character_nodes.stop_walking_sound()
		has_floor_collision = true
		return d
	if character_nodes.is_low_ceiling() and not is_crouching and has_floor_collision():
		sit_down()
	var movement_data = get_movement_data(is_player)
	update_state(movement_data)
	var characters = game_state.get_characters()
	var movement_process_data = process_movement(delta, movement_data.get_dir(), characters)
	has_floor_collision = movement_process_data.collides_floor
	d.is_moving = movement_process_data.is_walking
	d.is_rotating = process_rotation(not d.is_moving and is_player)
	if d.is_moving:
		character_nodes.play_walking_sound(is_sprinting)
	else:
		character_nodes.stop_walking_sound()
	for character in characters:
		if equals(character):
			continue
		if not update_ray_to_character(character):
			add_ray_to_character(character)
	if not is_visible_to_player():
		return d
	var model = get_model()
	model.rotate_head(movement_data.get_rotation_angle_to_target_deg())
	if d.is_moving or d.is_rotating:
		character_nodes.stop_rest_timer()
		model.walk(is_crouching, is_sprinting)
	else:
		character_nodes.start_rest_timer()
	return d