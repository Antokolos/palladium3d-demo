extends PLDCharacter
class_name PLDEnemy

signal attack_started(enemy, target)

const MAX_HITS = 3
const AGGRESSION_RANGE = 9.5
const TOO_FAR_RANGE = 10

onready var melee_damage_area = $MeleeDamageArea
onready var attack_timer = $AttackTimer
var hits = 0
var injury_rate = 20

func _ready():
	pass

### Use target ###

func use(player_node, camera_node):
	if is_activated() and can_be_attacked():
		hit(camera_node)

func add_highlight(player_node):
	if not is_activated() or not can_be_attacked() or is_dying():
		return ""
	return "E: Shoot"

func hit(hit_direction_node):
	if not is_activated():
		return
	elif hits > MAX_HITS:
		take_damage(true, hit_direction_node)
	else:
#		if fmod(hits, 2) == 0.0:
#			is_sprinting = true
		take_damage(false, hit_direction_node)
		hits = hits + 1

func activate():
	.activate()
	hits = 0
	is_sprinting = false
	$CutsceneTimer.start()

func get_nearest_party_member():
	var party = get_tree().get_nodes_in_group("party")
	var tgt = null
	var dist_squared_min
	var origin = get_global_transform().origin
	for ch in party:
		var dist_squared_cur = origin.distance_squared_to(ch.get_global_transform().origin)
		if not tgt:
			tgt = ch
			dist_squared_min = dist_squared_cur
			continue
		if dist_squared_cur < dist_squared_min:
			dist_squared_min = dist_squared_cur
			tgt = ch
	return tgt

func get_preferred_target():
	if not is_activated():
		return null
	return get_nearest_party_member() if is_aggressive() else .get_preferred_target()

func is_enemy():
	return true

func can_be_attacked():
	return false

func can_run():
	return true

func get_possible_attack_target():
	if not is_activated():
		return null
	for body in melee_damage_area.get_overlapping_bodies():
		if body.get_instance_id() == get_instance_id():
			continue
		if body.is_in_group("party"):
			return body
	return null

func attack_start(possible_attack_target):
	if not is_activated():
		return
	if attack_timer.is_stopped():
		is_sprinting = false
		emit_signal("attack_started", self, possible_attack_target)
		get_model().attack()
		attack_timer.start()

func take_damage(fatal, hit_direction_node):
	if not is_activated() or is_dying():
		return
	stop_cutscene()
	get_model().take_damage(fatal)
	push_back(get_push_vec(hit_direction_node))
	if fatal:
		$Body_CollisionShape.disabled = true
		$Feet_CollisionShape.disabled = false
		$StandingArea/CollisionShape.disabled = true
		melee_damage_area.get_node("CollisionShape").disabled = true

func _physics_process(delta):
	.do_process(delta)
	if not is_activated():
		return
	var dtp = get_distance_to_player()
	var aggressive = dtp < AGGRESSION_RANGE
	is_sprinting = aggressive
	set_aggressive(aggressive)
	if not is_aggressive():
		if not is_patrolling():
			set_patrolling(true)
		return
	var possible_attack_target = get_possible_attack_target()
	if possible_attack_target:
		attack_start(possible_attack_target)
	elif not attack_timer.is_stopped():
		attack_timer.stop()
		stop_cutscene()
	if not can_run():
		return
	if not is_sprinting and get_distance_to_target() > TOO_FAR_RANGE:
		is_sprinting = true

func _on_AttackTimer_timeout():
	if not is_activated():
		return
	if get_possible_attack_target():
		game_state.set_health(DB.PLAYER_NAME_HINT, game_state.player_health_current - injury_rate, game_state.player_health_max)
	else:
		stop_cutscene()
