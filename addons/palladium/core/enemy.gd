extends PLDCharacter
class_name PLDEnemy

const TOO_FAR_RANGE = 10
const AGGRESSION_RANGE = 11
const STOP_CHASING_RANGE = 12

export var max_hits = 0
var hits = 0

func _ready():
	get_tree().call_group("hideouts", "connect_signals", self)

func use_usable(player_node, usable):
	pass

func use_hideout(player_node, hideout):
	if not is_activated():
		return
	set_aggressive(false)
	stop_attack()

### Use target ###

func use(player_node, camera_node):
	if not is_activated():
		return false
	var u = .use(player_node, camera_node)
	var attacker = get_possible_attacker()
	if not u and attacker:
		ask_for_attack(attacker)
	return true

func ask_for_attack(attacker):
	attacker.attack_start(self)

func add_highlight(player_node):
	if not is_activated() or is_dying():
		return ""
	var h = .add_highlight(player_node)
	if not h.empty():
		return h
	var attacker = get_possible_attacker()
	if player_node.equals(attacker):
		return "E: " + tr("ACTION_SHOOT")
	elif attacker:
		return "E: " + tr("ACTION_SHOOT")
	return ""

func hit(injury_rate, hit_direction_node = null):
	if not is_activated():
		return
	elif max_hits > 0 and hits > max_hits:
		take_damage(true, hit_direction_node)
	else:
		take_damage(false, hit_direction_node)
		hits = hits + 1

func activate():
	.activate()
	hits = 0
	set_sprinting(false)
	character_nodes.start_cutscene_timer()

func get_preferred_target():
	if not is_activated():
		return null
	return get_aggression_target() if is_aggressive() else .get_preferred_target()

func set_states():
	set_states_for_character(get_nearest_character(true))

func set_states_for_character(character):
	if character.is_hidden() \
		or get_relationship() >= 0 \
		or get_morale() < 0:
		set_aggressive(false)
		return
	var dtp = get_distance_to_character(character)
	var is_aggressive = is_aggressive()
	if is_aggressive and (dtp > TOO_FAR_RANGE or character.is_sprinting()):
		set_sprinting(true)
	if not is_aggressive \
		and dtp < AGGRESSION_RANGE \
		and not has_obstacles_between(character):
		set_sprinting(true)
		set_aggressive(true)
	elif is_aggressive and dtp > STOP_CHASING_RANGE:
		set_aggressive(false)
		set_sprinting(false)

func _physics_process(delta):
	.do_process(delta, false)
	if not is_activated():
		return
	set_states()
	if not is_aggressive():
		var target = get_target_node()
		if target and not target.get_parent() is PLDPatrolArea:
			return
		if not is_patrolling():
			set_patrolling(true)
		return
	handle_attack()
