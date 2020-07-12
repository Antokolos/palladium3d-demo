extends PLDCharacter
class_name PLDEnemy

const MAX_HITS = 3
const TOO_FAR_RANGE = 10

onready var melee_damage_area = $MeleeDamageArea
onready var attack_timer = $AttackTimer
var activated = false
var hits = 0
var injury_rate = 20

func _ready():
	pass

### Use target ###

func use(player_node, camera_node):
	hit(camera_node)

func hit(hit_direction_node):
	if not activated:
		return
	elif hits > MAX_HITS:
		take_damage(true, hit_direction_node)
	else:
#		if fmod(hits, 2) == 0.0:
#			is_sprinting = true
		take_damage(false, hit_direction_node)
		hits = hits + 1

func add_highlight(player_node):
	if is_dying() or is_dead():
		return ""
	return "E: Shoot" if activated else ""

func activate():
	hits = 0
	is_sprinting = false
	get_model().activate()
	$CutsceneTimer.start()
	activated = true

func is_activated():
	return activated

func get_preferred_target():
	return game_params.get_player() if activated else null

func is_enemy():
	return true

func can_run():
	return true

func can_attack():
	for body in melee_damage_area.get_overlapping_bodies():
		if body.get_instance_id() == get_instance_id():
			continue
		if body.is_in_group("party"):
			return true
	return false

func attack():
	if attack_timer.is_stopped():
		is_sprinting = false
		get_model().attack()
		attack_timer.start()

func take_damage(fatal, hit_direction_node):
	if is_dying() or is_dead():
		return
	stop_cutscene()
	get_model().take_damage(fatal)
	push_back(get_push_vec(hit_direction_node))
	if fatal:
		$Body_CollisionShape.disabled = true
		$Feet_CollisionShape.disabled = false
		$StandingArea/CollisionShape.disabled = true

func _on_CutsceneTimer_timeout():
	set_look_transition(true)

func _physics_process(delta):
	if can_attack():
		attack()
	elif not attack_timer.is_stopped():
		attack_timer.stop()
		stop_cutscene()
	if not can_run():
		return
	if not is_sprinting and get_distance_to_target() > TOO_FAR_RANGE:
		is_sprinting = true

func _on_AttackTimer_timeout():
	if can_attack():
		game_params.set_health(game_params.PLAYER_NAME_HINT, game_params.player_health_current - injury_rate, game_params.player_health_max)
	else:
		stop_cutscene()
