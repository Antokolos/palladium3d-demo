extends Spatial
class_name PLDCharacterNodes

const FRIENDLY_FIRE_ENABLED = false
const OXYGEN_DECREASE_RATE = 5
const POISON_LETHALITY_RATE = 1

onready var character = get_parent()

onready var cutscene_timer = $CutsceneTimer
onready var oxygen_timer = $OxygenTimer
onready var poison_timer = $PoisonTimer
onready var stun_timer = $StunTimer
onready var attack_timer = $AttackTimer
onready var rest_timer = $RestTimer

onready var standing_area = $StandingArea
onready var melee_damage_area = $MeleeDamageArea
onready var ranged_damage_raycast = $RangedDamageRayCast
onready var rays_to_characters = $RaysToCharacters

onready var visibility_notifier = $VisibilityNotifier
onready var sound_player_walking = $SoundWalking
onready var sound_player_falling_to_floor = $SoundFallingToFloor
onready var sound_player_attack = $SoundAttack
onready var sound_player_miss = $SoundMiss

var injury_rate = 20
var walk_sound_ids = [ CHARS.SoundId.SOUND_WALK_NONE ]

func _ready():
	game_state.connect("player_underwater", self, "_on_player_underwater")
	game_state.connect("player_poisoned", self, "_on_player_poisoned")
	character.get_model().connect("cutscene_finished", self, "_on_cutscene_finished")
	melee_damage_area.monitoring = character.has_melee_attack()
	ranged_damage_raycast.enabled = character.has_ranged_attack()

func _on_player_underwater(player, enable):
	if player and not player.equals(character):
		return
	if enable and oxygen_timer.is_stopped():
		oxygen_timer.start()
	elif not enable and not oxygen_timer.is_stopped():
		oxygen_timer.stop()
		game_state.set_oxygen(character.get_name_hint(), game_state.player_oxygen_max, game_state.player_oxygen_max)

func _on_player_poisoned(player, enable):
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
	r.set_collision_mask_bit(1, true)
	r.set_collision_mask_bit(2, true)
	r.set_collision_mask_bit(10, true)
	r.set_collision_mask_bit(13, true)
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

func start_cutscene_timer():
	cutscene_timer.start()

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
	if walk_sound_ids[0] == mode and not replace_existing:
		return
	if replace_existing:
		walk_sound_ids[0] = mode
	else:
		walk_sound_ids.push_front(mode)
	sound_player_walking.stop()
	sound_player_walking.stream = CHARS.SOUND[mode] if mode != CHARS.SoundId.SOUND_WALK_NONE and CHARS.SOUND.has(mode) else null
	sound_player_walking.set_unit_db(0)

func restore_sound_walk_from(mode):
	if walk_sound_ids.size() > 1 and walk_sound_ids[0] == mode:
		walk_sound_ids.pop_front()
		set_sound_walk(walk_sound_ids[0])

func set_sound_attack(mode):
	sound_player_attack.stop()
	sound_player_attack.stream = CHARS.SOUND[mode] if CHARS.SOUND.has(mode) else null
	sound_player_attack.set_unit_db(0)

func set_sound_miss(mode):
	sound_player_miss.stop()
	sound_player_miss.stream = CHARS.SOUND[mode] if CHARS.SOUND.has(mode) else null
	sound_player_miss.set_unit_db(0)

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
			character.inc_stuns_count()
			common_utils.set_pause_scene(character, true)
			character.emit_signal("stun_started", character, item)
			stun_timer.start(weapon_data.stun_duration)
		else:
			game_state.get_hud().queue_popup_message(tr("MESSAGE_NOTHING_HAPPENS"))

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

func play_attack_sound():
	sound_player_attack.play()

func play_sound_miss():
	sound_player_miss.play()

func attack_start():
# TODO: Check it is OK
#	if not character.is_activated():
#		return
	if not is_attacking():
		attack_timer.start()

func stop_attack():
	if is_attacking():
		attack_timer.stop()

func start_rest_timer():
	if rest_timer.is_stopped():
		rest_timer.start()

func stop_rest_timer():
	rest_timer.stop()

func enable_areas(enable):
	standing_area.get_node("CollisionShape").disabled = not enable
	melee_damage_area.get_node("CollisionShape").disabled = not enable

func is_visible_to_player():
	return visibility_notifier.is_on_screen() and not has_obstacles_between(game_state.get_player())

func is_low_ceiling():
	# Make sure you've set proper collision layer bit for ceiling
	return standing_area.get_overlapping_bodies().size() > 0

func _on_HealTimer_timeout():
	if character.is_player():
		game_state.set_health(character.get_name_hint(), game_state.player_health_current + DB.HEALING_RATE, game_state.player_health_max)

func _on_CutsceneTimer_timeout():
	character.set_look_transition(true)

func _on_OxygenTimer_timeout():
	if oxygen_timer.is_stopped():
		return
	game_state.set_oxygen(character.get_name_hint(), game_state.player_oxygen_current - OXYGEN_DECREASE_RATE, game_state.player_oxygen_max)

func _on_PoisonTimer_timeout():
	if poison_timer.is_stopped():
		return
	game_state.set_health(character.get_name_hint(), game_state.player_health_current - POISON_LETHALITY_RATE, game_state.player_health_max)

func _on_StunTimer_timeout():
	common_utils.set_pause_scene(character, false)
	character.emit_signal("stun_finished", character)

func _on_cutscene_finished(player, player_model, cutscene_id, was_active):
	if is_attacking() and player_model.is_attack_cutscene(cutscene_id):
		attack_timer.stop()
		if not was_active:
			_on_AttackTimer_timeout()

func _on_AttackTimer_timeout():
# TODO: Check it is OK
#	if not character.is_activated():
#		return
	var last_attack_target = character.get_last_attack_target()
	var attack_target = get_possible_attack_target(true)
	if attack_target:
		play_attack_sound()
		if attack_target.is_in_group("party"):
			if FRIENDLY_FIRE_ENABLED \
				or not character.is_in_group("party"):
				game_state.set_health(CHARS.PLAYER_NAME_HINT, game_state.player_health_current - injury_rate, game_state.player_health_max)
		elif attack_target.is_in_group("enemies"):
			attack_target.hit(null)
		if last_attack_target and attack_target.get_instance_id() != last_attack_target.get_instance_id():
			last_attack_target.miss(null)
	else:
		play_sound_miss()
		if last_attack_target:
			last_attack_target.miss(null)
		#character.stop_cutscene()
	character.emit_signal("attack_finished", self, attack_target, last_attack_target)
	character.clear_point_of_interest()

func _on_RestTimer_timeout():
	character.get_model().look()

func _on_VisibilityNotifier_screen_entered():
	character.emit_signal("visibility_to_player_changed", character, false, true)
	if character.is_in_party():
		character.invoke_physics_pass()

func _on_VisibilityNotifier_screen_exited():
	character.emit_signal("visibility_to_player_changed", character, true, false)
