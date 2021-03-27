extends PLDPathfinder
class_name PLDCharacter

signal player_changed(player_new, player_prev)
signal visibility_to_player_changed(player_node, previous_state, new_state)
signal patrolling_changed(player_node, previous_state, new_state)
signal aggressive_changed(player_node, previous_state, new_state)
signal crouching_changed(player_node, previous_state, new_state)
signal floor_collision_changed(player_node, previous_state, new_state)
signal attack_started(player_node, target)
signal attack_stopped(player_node, target)
signal attack_finished(player_node, target, previous_target)
signal stun_started(player_node, weapon)
signal stun_finished(player_node)
signal take_damage(player_node, fatal, hit_direction_node)

const GRAVITY_DEFAULT = 10.2
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
export var can_hide = true
export var can_read = false

onready var character_nodes = $character_nodes
onready var animation_player = $AnimationPlayer

var vel = Vector3()

var is_hidden = false
var is_patrolling = false
var is_aggressive = false
var is_crouching = false
var is_sprinting = false
var is_underwater = false
var is_air_pocket = false  # is_air_pocket flag is not stored in the save file
var is_poisoned = false
var intoxication : int = 0
var relationship : int = 0
var morale : int = 0
var stuns_count : int = 0
var has_floor_collision = true
var force_physics = false
var force_no_physics = false
var force_visibility = false
var last_attack_target = null

func _ready():
	game_state.connect("player_underwater", self, "_on_player_underwater")
	game_state.connect("player_poisoned", self, "_on_player_poisoned")
	game_state.connect("player_registered", self, "_on_player_registered")
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

func can_hide():
	return can_hide

func can_read():
	return can_read

func handle_attack():
	var possible_target = character_nodes.get_possible_attack_target(false)
	if not possible_target:
		stop_attack()
		return
	var aggression_target = get_aggression_target()
	if not aggression_target:
		stop_attack()
		return
	if possible_target.get_instance_id() != aggression_target.get_instance_id():
		stop_attack()
		return
	attack_start(possible_target)

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
		emit_signal("attack_stopped", self, last_attack_target)
		clear_point_of_interest()
		last_attack_target = null

func set_last_attack_target(last_attack_target):
	self.last_attack_target = last_attack_target

func get_last_attack_target():
	return last_attack_target

func is_attacking():
	return character_nodes.is_attacking() or get_model().is_attacking()

func hit(injury_rate, hit_direction_node = null):
	pass

func miss(hit_direction_node = null):
	pass

func take_damage(fatal, hit_direction_node):
	if not is_activated() or is_dying():
		return
	emit_signal("take_damage", self, fatal, hit_direction_node)
	stop_cutscene()
	get_model().take_damage(fatal)
	push_back(get_push_vec(hit_direction_node))

func kill_on_load():
	get_model().kill_on_load()

func kill():
	if is_player_controlled():
		game_state.game_over()
	else:
		get_model().kill()

func enable_collisions_and_interaction(enable):
	if has_node("UpperBody_CollisionShape"):
		$UpperBody_CollisionShape.disabled = not enable
	$Body_CollisionShape.disabled = not enable
	$Feet_CollisionShape.disabled = not enable
	character_nodes.enable_areas(enable)

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
	return item.is_weapon()

func can_be_given(item):
	if not item:
		return false
	return item.can_be_given()

func add_highlight(player_node):
	var hud = game_state.get_hud()
	if hud and hud.get_active_item():
		var item = hud.get_active_item()
		if item_is_weapon(item):
			return common_utils.get_action_input_control() + tr("ACTION_ATTACK")
		if can_be_given(item) and conversation_manager.meeting_is_finished(player_node.get_name_hint(), get_name_hint()):
			return common_utils.get_action_input_control() + tr("ACTION_GIVE")
	return ""

### Getting character's parts ###

func get_model_holder():
	return get_node("Model")

func get_model():
	return get_model_holder().get_child(0)

func get_cam_holder():
	return get_node("Rotation_Helper/Camera")

func get_cam():
	var cutscene_cam = cutscene_manager.get_cam()
	var cam_holder = get_cam_holder()
	return (
		cutscene_cam
			if cutscene_cam
			else
				cam_holder.get_child(0)
				if cam_holder and cam_holder.get_child_count() > 0
				else null
	)

### States ###

func become_player():
	if not is_activated():
		activate()
	if not is_in_party():
		join_party()
	var model = get_model()
	model.set_simple_mode(true)
	var player = game_state.get_player()
	deactivate()
	if not player or is_player():
		var cam = get_cam()
		if not cam:
			cam = load("res://addons/palladium/core/camera.tscn").instance()
			get_cam_holder().add_child(cam)
		cam.rebuild_exceptions(self)
	else:
		player.deactivate()
		var cam_holder = get_cam_holder()
		var player_cam_holder = player.get_cam_holder()
		var cutscene_cam = cutscene_manager.get_cam()
		var camera = player_cam_holder.get_child(0) if player_cam_holder.get_child_count() > 0 else null
		if camera:
			player_cam_holder.remove_child(camera)
			cam_holder.add_child(camera)
			camera.rebuild_exceptions(self)
		elif cutscene_cam:
			cutscene_cam.rebuild_exceptions(self)
			cutscene_manager.stop_cutscene(self)
		var player_model = player.get_model()
		player_model.set_simple_mode(false)
		player.activate()
	game_state.set_player_name_hint(get_name_hint())
	game_state.set_underwater(self, is_underwater())
	game_state.set_poisoned(self, is_poisoned(), get_intoxication())
	activate()
	emit_signal("player_changed", self, player)

func join_party():
	.join_party()
	set_sprinting(false)

func is_underwater():
	return is_underwater

func set_underwater(enable):
	is_underwater = enable
	if not enable:
		is_air_pocket = false
	vel.y = -DIVE_SPEED if enable or vel.y <= 0.0 else BOB_UP_SPEED
	character_nodes.set_underwater(enable)

func is_air_pocket():
	return is_air_pocket

func set_air_pocket(enable):
	is_air_pocket = enable

func _on_player_underwater(player, enable):
	if player and not equals(player):
		return
	set_underwater(enable)

func is_poisoned():
	return is_poisoned

func set_poisoned(enable):
	is_poisoned = enable

func get_intoxication() -> int:
	return intoxication

func set_intoxication(intoxication : int):
	self.intoxication = intoxication

func _on_player_poisoned(player, enable, intoxication_rate):
	if player and not equals(player):
		return
	set_poisoned(enable)
	set_intoxication(intoxication_rate)

func _on_player_registered(player):
	if not player:
		push_error("Player not set")
		return
	player.connect("aggressive_changed", self, "_on_aggressive_changed")
	var model = player.get_model()
	if not model:
		push_error("Model not set")
		return
	model.connect("character_dead", self, "_on_character_dead")
	model.connect("character_dying", self, "_on_character_dying")

func _on_aggressive_changed(player_node, previous_state, new_state):
	if new_state:
		return
	if equals(player_node) and get_point_of_interest():
		clear_point_of_interest()
	else:
		clear_poi_if_it_is(player_node)

func _on_character_dead(player):
	if equals(player):
		stop_attack()
		enable_collisions_and_interaction(false)
	clear_poi_if_it_is(player)
	._on_character_dead(player)

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
	if is_hidden and not enable:
		enable_collisions_and_interaction(true)
		is_hidden = false
	elif not is_hidden and enable:
		is_hidden = true
		enable_collisions_and_interaction(false)
	else:
		return
	visible = not enable
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

func get_nearest_character(party_members_only = false):
	var characters = game_state.get_characters()
	var tgt = null
	var dist_squared_min
	var origin = get_global_transform().origin
	for ch in characters:
		if equals(ch):
			continue
		if not ch.is_activated():
			continue
		if ch.is_dying():
			continue
		if party_members_only and not ch.is_in_party():
			continue
		var dist_squared_cur = origin.distance_squared_to(ch.get_global_transform().origin)
		if not tgt:
			tgt = ch
			dist_squared_min = dist_squared_cur
			continue
		if dist_squared_cur < dist_squared_min:
			dist_squared_min = dist_squared_cur
			tgt = ch
	return tgt

func get_aggression_target():
	return get_nearest_character(true)

func set_target_node(node, update_navpath = true, force_no_sprinting = false):
	.set_target_node(node, update_navpath)
	if not node or is_player_controlled():
		return
	if force_no_sprinting:
		set_sprinting(false)
		return
	if not is_in_party() and get_morale() >= 0:
		set_sprinting(false)
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

func is_cutscene(cutscene_id = -1):
	return get_model().is_cutscene(cutscene_id)

func play_cutscene(cutscene_id):
	get_model().play_cutscene(cutscene_id)
	character_nodes.start_cutscene_timer()

func play_jumpscare(hideout):
	get_model().play_jumpscare(hideout)

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

func sit_down_change_collisions():
	if animation_player.is_playing():
		return false
	animation_player.play("crouch")
	return true

func sit_down():
	if not sit_down_change_collisions():
		return
	get_model().sit_down()
	var is_player = is_player()
	if is_player:
		var companions = game_state.get_companions()
		for companion in companions:
			companion.sit_down()
	is_sprinting = false
	is_crouching = true
	emit_signal("crouching_changed", self, false, true)

func stand_up_change_collisions():
	if character_nodes.is_low_ceiling():
		# I.e. if the player is crouching and something is above the head, do not allow to stand up.
		return false
	if animation_player.is_playing():
		return false
	animation_player.play_backwards("crouch")
	return true

func stand_up():
	if not stand_up_change_collisions():
		return
	get_model().stand_up()
	var is_player = is_player()
	if is_player:
		var companions = game_state.get_companions()
		for companion in companions:
			companion.stand_up()
	is_crouching = false
	emit_signal("crouching_changed", self, true, false)

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

func get_relationship() -> int:
	return relationship

func set_relationship(relationship : int):
	self.relationship = relationship

func get_morale() -> int:
	return morale

func set_morale(morale : int):
	self.morale = morale

func get_stuns_count() -> int:
	return stuns_count

func set_stuns_count(stuns_count : int):
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
	return true

func invoke_physics_pass():
	set_has_floor_collision(false)
	var v = Vector3()
	v.y = vel.y
	move_and_slide(
		v,
		Vector3.UP,
		true,
		4,
		MAX_SLOPE_ANGLE_RAD,
		is_in_party()
	)

func get_snap():
	return Vector3.UP

func is_need_to_use_physics(characters):
	if force_physics:
		return true
	if force_no_physics:
		return false
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

func has_movement(v, fc):
	return (
		v.x >= MIN_MOVEMENT \
			or v.x <= -MIN_MOVEMENT \
			or v.z >= MIN_MOVEMENT \
			or v.z <= -MIN_MOVEMENT \
			or v.y > 0 \
			or (not is_air_pocket and not fc)
	)

func move_without_physics(hvel, fc, delta):
	if has_movement(hvel, fc):
		global_translate(hvel * delta)
	return hvel

func process_movement(delta, dir, characters):
	var target = Vector3.ZERO if is_movement_disabled() else dir
	var is_need_to_use_physics = is_need_to_use_physics(characters)
	if is_need_to_use_physics:
		target.y = 0
	target = target.normalized()

	if is_air_pocket:
		vel.y = 0
	else:
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
		if force_physics or has_movement(vel, has_floor_collision()):
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
		var fc = has_floor_collision()
		vel = move_without_physics(hvel, fc, delta)
		return { "is_walking" : has_movement(vel, fc), "collides_floor" : fc }
	
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
			if not is_player_controlled():
				vel = vel - character.vel
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
	return { "is_walking" : has_movement(vel, collides_floor), "collides_floor" : collides_floor }

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

func is_force_physics():
	return force_physics

func set_force_physics(force_physics):
	self.force_physics = force_physics

func is_force_no_physics():
	return force_no_physics

func set_force_no_physics(force_no_physics):
	self.force_no_physics = force_no_physics

func is_force_visibility():
	return force_visibility

func set_force_visibility(force_visibility):
	self.force_visibility = force_visibility

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

func set_has_floor_collision(fc):
	var fc_prev = has_floor_collision
	has_floor_collision = fc
	if fc_prev != fc:
		emit_signal(
			"floor_collision_changed",
			self,
			fc_prev,
			fc
		)
		if is_player():
			var characters = game_state.get_characters()
			for character in characters:
				if equals(character):
					continue
				character.invoke_physics_pass()

func do_process(delta, is_player):
	var d = { "is_moving" : false, "is_rotating" : false }
	var poi = get_point_of_interest()
	var player_is_crouching = false
	var characters = game_state.get_characters()
	for character in characters:
		if character.is_player_controlled():
			player_is_crouching = character.is_crouching()
		if equals(character):
			continue
		if not update_ray_to_character(character):
			add_ray_to_character(character)
		if poi and has_obstacles_between(character):
			if clear_poi_if_it_is(character):
				poi = null
	if not poi and (not is_activated() or is_movement_disabled() or is_hidden()):
		character_nodes.stop_walking_sound()
		set_has_floor_collision(true)
		return d
	var movement_data = get_movement_data(is_player)
	update_state(movement_data)
	var movement_process_data = process_movement(delta, movement_data.get_dir(), characters)
	set_has_floor_collision(movement_process_data.collides_floor)
	d.is_moving = movement_process_data.is_walking
	d.is_rotating = process_rotation(not d.is_moving and is_player)
	if d.is_moving:
		is_air_pocket = false
		character_nodes.play_walking_sound(is_sprinting)
	else:
		character_nodes.stop_walking_sound()
	if d.is_rotating:
		is_air_pocket = false
	if has_floor_collision():
		var low_ceiling = character_nodes.is_low_ceiling()
		if low_ceiling and not is_crouching:
			sit_down()
		elif not low_ceiling \
			and is_crouching \
			and not player_is_crouching \
			and is_in_party():
			stand_up() 
	if not is_visible_to_player() and not force_visibility:
		return d
	var model = get_model()
	model.rotate_head(movement_data.get_rotation_angle_to_target_deg())
	if d.is_moving or d.is_rotating:
		character_nodes.stop_rest_timer()
		model.walk(is_crouching, is_sprinting)
	else:
		character_nodes.start_rest_timer()
	return d