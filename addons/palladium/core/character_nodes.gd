extends Spatial
class_name PLDCharacterNodes

const OXYGEN_DECREASE_RATE = 5
const POISON_LETHALITY_RATE = 1
const SOUND_PATH_TEMPLATE = "res://sound/environment/%s"

enum SoundId {
	SOUND_WALK_NONE,
	SOUND_WALK_SAND,
	SOUND_WALK_WATER,
	SOUND_WALK_SWIM,
	SOUND_WALK_GRASS,
	SOUND_WALK_CONCRETE,
	SOUND_WALK_SKELETON,
	SOUND_WALK_MINOTAUR,
	SOUND_ATTACK_GUNSHOT,
	SOUND_ATTACK_SWOOSH,
	SOUND_ATTACK_AXE_ON_STONE
}

onready var character = get_parent()

onready var animation_player = $AnimationPlayer
onready var cutscene_timer = $CutsceneTimer
onready var oxygen_timer = $OxygenTimer
onready var poison_timer = $PoisonTimer
onready var stun_timer = $StunTimer
onready var attack_timer = $AttackTimer
onready var rest_timer = $RestTimer

onready var standing_area = $StandingArea
onready var melee_damage_area = $MeleeDamageArea

onready var visibility_notifier = $VisibilityNotifier
onready var sound_player_walking = $SoundWalking
onready var sound_player_falling_to_floor = $SoundFallingToFloor
onready var sound_player_attack = $SoundAttack
onready var sound_player_miss = $SoundMiss
onready var sound = {
	SoundId.SOUND_WALK_NONE : null,
	SoundId.SOUND_WALK_SAND : load(SOUND_PATH_TEMPLATE % "161815__dasdeer__sand-walk.ogg"),
	SoundId.SOUND_WALK_WATER : load(SOUND_PATH_TEMPLATE % "water_steps.ogg"),
	SoundId.SOUND_WALK_SWIM : load(SOUND_PATH_TEMPLATE % "man_swimming.ogg"),
	SoundId.SOUND_WALK_GRASS : load(SOUND_PATH_TEMPLATE % "400123__harrietniamh__footsteps-on-grass.ogg"),
	SoundId.SOUND_WALK_CONCRETE : load(SOUND_PATH_TEMPLATE % "336598__inspectorj__footsteps-concrete-a.ogg"),
	SoundId.SOUND_WALK_SKELETON : load(SOUND_PATH_TEMPLATE % "skeleton_walk.ogg"),
	SoundId.SOUND_WALK_MINOTAUR : load(SOUND_PATH_TEMPLATE % "minotaur_walk_reverb_short.ogg"),
	SoundId.SOUND_ATTACK_GUNSHOT : load(SOUND_PATH_TEMPLATE % "Labyrinth_gunshot.wav"),
	SoundId.SOUND_ATTACK_SWOOSH : load(SOUND_PATH_TEMPLATE % "sword_swing.ogg"),
	SoundId.SOUND_ATTACK_AXE_ON_STONE : load(SOUND_PATH_TEMPLATE % "pickaxe3.ogg")
}

var injury_rate = 20
var walk_sound_ids = [ SoundId.SOUND_WALK_NONE ]

func _ready():
	game_state.connect("player_underwater", self, "_on_player_underwater")
	game_state.connect("player_poisoned", self, "_on_player_poisoned")
	character.get_model().connect("cutscene_finished", self, "_on_cutscene_finished")

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

func sit_down():
	if animation_player.is_playing():
		return false
	animation_player.play("crouch")
	return true

func stand_up():
	if is_low_ceiling():
		# I.e. if the player is crouching and something is above the head, do not allow to stand up.
		return false
	if animation_player.is_playing():
		return false
	animation_player.play_backwards("crouch")
	return true

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
	if replace_existing:
		walk_sound_ids[0] = mode
	else:
		walk_sound_ids.push_front(mode)
	sound_player_walking.stop()
	sound_player_walking.stream = sound[mode] if sound.has(mode) else null
	sound_player_walking.set_unit_db(0)

func set_sound_attack(mode):
	sound_player_attack.stop()
	sound_player_attack.stream = sound[mode] if sound.has(mode) else null
	sound_player_attack.set_unit_db(0)

func set_sound_miss(mode):
	sound_player_miss.stop()
	sound_player_miss.stream = sound[mode] if sound.has(mode) else null
	sound_player_miss.set_unit_db(0)

func set_underwater(enable):
	if enable:
		if walk_sound_ids[0] != SoundId.SOUND_WALK_SWIM:
			set_sound_walk(SoundId.SOUND_WALK_SWIM, false)
		game_state.change_music_to(PLDGameState.MusicId.UNDERWATER, false)
	else:
		if walk_sound_ids[0] == SoundId.SOUND_WALK_SWIM:
			walk_sound_ids.pop_front()
		if walk_sound_ids[0] != SoundId.SOUND_WALK_NONE:
			set_sound_walk(walk_sound_ids[0])
		game_state.restore_music()

func use_weapon(item):
	if not item:
		return
	if DB.is_weapon_stun(item.item_id):
		var weapon_data = DB.get_weapon_stun_data(item.item_id)
		if weapon_data.stun_duration > 0:
			game_state.play_sound(PLDGameState.SoundId.SNAKE_HISS)
			character.inc_stuns_count()
			common_utils.set_pause_scene(character, true)
			stun_timer.start(weapon_data.stun_duration)

func get_possible_attack_target():
	if not character.is_activated():
		return null
	for body in melee_damage_area.get_overlapping_bodies():
		if character.equals(body):
			continue
		if body.is_in_group("party"):
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
	return visibility_notifier.is_on_screen()

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

func _on_cutscene_finished(player, cutscene_id):
	# TODO: maybe check that cutscene_id is attack cutscene???
	if is_attacking():
		attack_timer.stop()
		_on_AttackTimer_timeout()

func _on_AttackTimer_timeout():
# TODO: Check it is OK
#	if not character.is_activated():
#		return
	if get_possible_attack_target():
		play_attack_sound()
		game_state.set_health(CHARS.PLAYER_NAME_HINT, game_state.player_health_current - injury_rate, game_state.player_health_max)
	else:
		play_sound_miss()
		#character.stop_cutscene()
	character.clear_point_of_interest()

func _on_RestTimer_timeout():
	character.get_model().look()

func _on_VisibilityNotifier_screen_entered():
	character.emit_signal("visibility_to_player_changed", character, false, true)
	if character.is_in_party():
		character.move_and_collide(PLDCharacter.GRAVITY_DEFAULT * Vector3.DOWN)

func _on_VisibilityNotifier_screen_exited():
	character.emit_signal("visibility_to_player_changed", character, true, false)
