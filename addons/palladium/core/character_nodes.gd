extends Spatial
class_name PLDCharacterNodes

const FRIENDLY_FIRE_ENABLED = false
const OXYGEN_DECREASE_RATE = 5
const INJURY_RATE = 20

onready var character = get_parent()

onready var oxygen_timer = $OxygenTimer
onready var poison_timer = $PoisonTimer
onready var stun_timer = $StunTimer
onready var attack_timer = $AttackTimer
onready var rest_timer = $RestTimer

onready var melee_damage_area = $MeleeDamageArea
onready var ranged_damage_raycast = $RangedDamageRayCast
onready var standing_raycast = $StandingRayCast
onready var under_feet_raycast = $UnderFeetRayCast
onready var rays_to_characters = $RaysToCharacters

onready var visibility_notifier = $VisibilityNotifier
onready var sound_player_walking = $SoundWalking
onready var sound_player_falling_to_floor = $SoundFallingToFloor
onready var sound_player_angry = $SoundAngry
onready var sound_player_pain = $SoundPain
onready var sound_player_attack = $SoundAttack
onready var sound_player_miss = $SoundMiss

var walk_sound_ids = [ CHARS.SoundId.SOUND_WALK_NONE ]

func _ready():
	game_state.connect("player_underwater", self, "_on_player_underwater")
	game_state.connect("player_poisoned", self, "_on_player_poisoned")
	character.get_model().connect("cutscene_finished", self, "_on_cutscene_finished")
	melee_damage_area.monitoring = character.has_melee_attack()
	ranged_damage_raycast.enabled = character.has_ranged_attack()
	standing_raycast.add_exception(character)
	under_feet_raycast.add_exception(character)

func _on_player_underwater(player, enable):
	if player and not player.equals(character):
		return
	if enable and oxygen_timer.is_stopped():
		oxygen_timer.start()
	elif not enable:
		if not oxygen_timer.is_stopped():
			oxygen_timer.stop()
		game_state.set_oxygen(character, game_state.player_oxygen_max, game_state.player_oxygen_max)

func _on_player_poisoned(player, enable, intoxication_rate):
	if player and not player.equals(character):
		return
	if enable and poison_timer.is_stopped():
		poison_timer.start()
	elif not enable and not poison_timer.is_stopped():
		poison_timer.stop()

func get_rays_to_characters():
	return rays_to_characters

func get_rays_to_characters_pos():
	return get_rays_to_characters().get_global_transform().origin

func get_ray_to_character_name(another_character):
	return "ray_" + another_character.get_name_hint()

func get_ray_to_character(another_character):
	if not another_character:
		return null
	var ray_name = get_ray_to_character_name(another_character)
	return rays_to_characters.get_node(ray_name) \
			if rays_to_characters.has_node(ray_name) \
			else null

func add_ray_to_character(another_character):
	var ray_name = get_ray_to_character_name(another_character)
	if rays_to_characters.has_node(ray_name):
		return null
	var r = RayCast.new()
	r.set_name(ray_name)
	r.enabled = another_character.is_activated()
	r.set_collision_mask_bit(0, false) # Default layer is NOT a collision
	r.set_collision_mask_bit(1, true) # Collides with walls
	r.set_collision_mask_bit(2, true) # Collides with floor
	r.set_collision_mask_bit(3, false) # Interactives is NOT a collision
	r.set_collision_mask_bit(4, true) # Collides with doors
	r.set_collision_mask_bit(10, true) # Collides with ceiling
	r.set_collision_mask_bit(11, false) # Party is NOT a collision
	r.set_collision_mask_bit(12, false) # Enemies is NOT a collision
	r.set_collision_mask_bit(13, false) # Obstacles is NOT a collision
	rays_to_characters.add_child(r)
	update_ray_to_character(another_character, r)
	return r

func update_ray_to_character(another_character, ray = null):
	var r = ray if ray else get_ray_to_character(another_character)
	if r:
		r.cast_to = r.to_local(another_character.get_rays_to_characters_pos())
		return true
	return false

func has_obstacles_between(another_character):
	var r = get_ray_to_character(another_character)
	return r and r.is_colliding()

func enable_rays_to_character(another_character, enable):
	var r = get_ray_to_character(another_character)
	if r:
		r.enabled = enable
		return true
	return false

func play_walking_sound(is_sprinting):
	if not sound_player_walking.is_playing():
		sound_player_walking.play()
	var new_pitch_scale = 2 if is_sprinting else 1
	if new_pitch_scale != sound_player_walking.pitch_scale:
		sound_player_walking.pitch_scale = new_pitch_scale

func stop_walking_sound():
	sound_player_walking.stop()

func play_sound_falling_to_floor():
	sound_player_falling_to_floor.play()

func set_sound_walk(mode, replace_existing = true):
	var stream = CHARS.SOUND[mode] if mode != CHARS.SoundId.SOUND_WALK_NONE and CHARS.SOUND.has(mode) else null
	if (
		walk_sound_ids[0] == mode
		and stream and sound_player_walking.stream
		and common_utils.is_same_resource(stream, sound_player_walking.stream)
	):
		return
	if replace_existing:
		walk_sound_ids[0] = mode
	else:
		walk_sound_ids.push_front(mode)
	sound_player_walking.stop()
	sound_player_walking.set_unit_db(0)
	if not common_utils.set_stream_loop(stream, true):
		sound_player_walking.stream = null
		return
	sound_player_walking.stream = stream

func restore_sound_walk_from(mode):
	if walk_sound_ids.size() > 1 and walk_sound_ids[0] == mode:
		walk_sound_ids.pop_front()
		set_sound_walk(walk_sound_ids[0])

func set_sound_angry(mode):
	sound_player_angry.stop()
	sound_player_angry.set_unit_db(6)
	var stream = CHARS.SOUND[mode] if CHARS.SOUND.has(mode) else null
	if not common_utils.set_stream_loop(stream, false):
		sound_player_angry.stream = null
		return
	sound_player_angry.stream = stream

func set_sound_pain(mode):
	sound_player_pain.stop()
	sound_player_pain.set_unit_db(6)
	var stream = CHARS.SOUND[mode] if CHARS.SOUND.has(mode) else null
	if not common_utils.set_stream_loop(stream, false):
		sound_player_pain.stream = null
		return
	sound_player_pain.stream = stream

func set_sound_attack(mode):
	sound_player_attack.stop()
	sound_player_attack.set_unit_db(0)
	var stream = CHARS.SOUND[mode] if CHARS.SOUND.has(mode) else null
	if not common_utils.set_stream_loop(stream, false):
		sound_player_attack.stream = null
		return
	sound_player_attack.stream = stream

func set_sound_miss(mode):
	sound_player_miss.stop()
	sound_player_miss.set_unit_db(0)
	var stream = CHARS.SOUND[mode] if CHARS.SOUND.has(mode) else null
	if not common_utils.set_stream_loop(stream, false):
		sound_player_miss.stream = null
		return
	sound_player_miss.stream = stream

func set_underwater(enable):
	if enable:
		set_sound_walk(CHARS.SoundId.SOUND_WALK_SWIM, false)
		MEDIA.change_music_to(MEDIA.MusicId.UNDERWATER, false)
		settings.set_reverb(false)
	else:
		restore_sound_walk_from(CHARS.SoundId.SOUND_WALK_SWIM)
		MEDIA.restore_music_from(MEDIA.MusicId.UNDERWATER)
		settings.set_reverb(game_state.get_level().is_inside())

func use_weapon(item):
	if not item:
		return
	if DB.is_weapon_stun(item.item_id):
		var weapon_data = DB.get_weapon_stun_data(item.item_id)
		if weapon_data.stun_duration > 0:
			MEDIA.play_sound(weapon_data.sound_id)
			stun_start(item, weapon_data.stun_duration)
		else:
			game_state.get_hud().queue_popup_message("MESSAGE_NOTHING_HAPPENS")

func stun_start(item, stun_duration):
	character.inc_stuns_count()
	common_utils.set_pause_scene(character, true)
	character.emit_signal("stun_started", character, item)
	character.clear_target_node()
	stun_timer.start(stun_duration)

func is_stunned():
	return not stun_timer.is_stopped()

func stun_stop(prematurely):
	var was_stunned = not stun_timer.is_stopped()
	if was_stunned:
		stun_timer.stop()
	if prematurely and not was_stunned:
		# It looks like that the stun has been already stopped by timer
		return was_stunned
	common_utils.set_pause_scene(character, false)
	character.emit_signal("stun_finished", character, prematurely)
	return was_stunned

func has_floor_collision():
	return under_feet_raycast.is_colliding()

func get_possible_attack_target(update_collisions):
	if not character.is_activated():
		return null
	if character.has_melee_attack():
		for body in melee_damage_area.get_overlapping_bodies():
			if character.equals(body):
				continue
			if body.is_in_group("party") or body.is_in_group("enemies"):
				return body
	if character.has_ranged_attack():
		if update_collisions:
			ranged_damage_raycast.force_raycast_update()
		if ranged_damage_raycast.is_colliding():
			var body = ranged_damage_raycast.get_collider()
			if body.is_in_group("party") or body.is_in_group("enemies"):
				return body
	return null

func is_attacking():
	return not attack_timer.is_stopped()

func play_angry_sound():
	sound_player_angry.play()

func play_pain_sound():
	sound_player_pain.play()

func play_attack_sound():
	sound_player_attack.play()

func play_sound_miss():
	sound_player_miss.play()

func attack_start(immediately = false):
# TODO: Check it is OK
#	if not character.is_activated():
#		return
	if not is_attacking():
		if immediately:
			_on_AttackTimer_timeout()
		else:
			attack_timer.start()

func stop_attack():
	if is_attacking():
		attack_timer.stop()

func start_rest_timer():
	if rest_timer.is_stopped():
		rest_timer.start()

func stop_rest_timer():
	rest_timer.stop()

func stop_all():
	stop_rest_timer()
	stop_attack()
	stun_timer.stop()
	poison_timer.stop()
	oxygen_timer.stop()

func enable_areas_and_raycasts(enable):
	standing_raycast.enabled = enable
	under_feet_raycast.enabled = enable
	ranged_damage_raycast.enabled = enable
	melee_damage_area.get_node("CollisionShape").disabled = not enable

func is_visible_to_player():
	return visibility_notifier.is_on_screen() and not has_obstacles_between(game_state.get_player())

func is_low_ceiling():
	# Make sure you've set proper collision layer bit for ceiling
	return standing_raycast.is_colliding()

func _on_HealTimer_timeout():
	if (
		not character.is_player()
		or not game_state.is_level_ready()
		or not oxygen_timer.is_stopped()
		or not poison_timer.is_stopped()
	):
		return
	game_state.set_health(character, game_state.player_health_current + DB.HEALING_RATE, game_state.player_health_max)

func _on_OxygenTimer_timeout():
	if oxygen_timer.is_stopped():
		return
	var oxygen_new = game_state.player_oxygen_current - OXYGEN_DECREASE_RATE
	game_state.set_oxygen(character, oxygen_new, game_state.player_oxygen_max)

func _on_PoisonTimer_timeout():
	if poison_timer.is_stopped():
		return
	game_state.set_health(character, game_state.player_health_current - character.get_intoxication(), game_state.player_health_max)

func _on_StunTimer_timeout():
	stun_stop(false)

func _on_cutscene_finished(player, player_model, cutscene_id, was_active):
	if is_attacking() and player_model.is_attack_cutscene(cutscene_id):
		attack_timer.stop()
		if not was_active:
			_on_AttackTimer_timeout()

func _on_AttackTimer_timeout():
# TODO: Check it is OK
#	if not character.is_activated():
#		return
	var last_attack_data = character.get_last_attack_data()
	var last_attack_target = last_attack_data.target
	var attack_target = get_possible_attack_target(true)
	if attack_target:
		play_attack_sound()
		if attack_target.is_in_group("party"):
			if FRIENDLY_FIRE_ENABLED \
				or not character.is_in_group("party"):
				attack_target.hit(INJURY_RATE)
		elif attack_target.is_in_group("enemies"):
			attack_target.hit(INJURY_RATE)
		if last_attack_target and attack_target.get_instance_id() != last_attack_target.get_instance_id():
			last_attack_target.miss()
	else:
		play_sound_miss()
		if last_attack_target:
			last_attack_target.miss()
		#character.stop_cutscene()
	character.emit_signal("attack_finished", character, attack_target, last_attack_target, last_attack_data.anim_idx)
	character.clear_point_of_interest()
	character.clear_last_attack_data()

func _on_RestTimer_timeout():
	stop_walking_sound()
	character.get_model().look()

func _on_VisibilityNotifier_screen_entered():
	character.emit_signal("visibility_to_player_changed", character, false, true)
	if character.is_in_party():
		character.invoke_physics_pass()

func _on_VisibilityNotifier_screen_exited():
	character.emit_signal("visibility_to_player_changed", character, true, false)
