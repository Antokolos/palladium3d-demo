extends PLDCharacter
class_name PLDEnemy

const TOO_FAR_RANGE = 10
const AGGRESSION_RANGE = 12
const STOP_CHASING_RANGE = 14

export var max_hits = 0
var hits = 0

onready var hideout_decision_timer = $HideoutDecisionTimer

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
		return common_utils.get_action_input_control() + tr("ACTION_SHOOT")
	elif attacker:
		return common_utils.get_action_input_control() + tr("ACTION_SHOOT")
	return ""

func hit(injury_rate, hit_direction_node = null, hit_dir_vec = Z_DIR):
	if not is_activated():
		return
	.hit(injury_rate, hit_direction_node, hit_dir_vec)
	if max_hits > 0 and hits > max_hits:
		take_damage(true, hit_direction_node, hit_dir_vec)
	else:
		take_damage(false, hit_direction_node, hit_dir_vec)
		hits = hits + 1

func activate():
	.activate()
	hits = 0
	set_sprinting(false)

func get_preferred_target():
	if not is_activated():
		return null
	return get_aggression_target() if is_aggressive() else .get_preferred_target()

func set_states():
	set_states_for_character(get_nearest_character(true))

func set_states_for_character(character):
	if not character:
		return
	if (
		get_relationship() >= 0
		or get_morale() < 0
		or (
			character.is_hidden()
			and (
				not game_state.is_flashlight_on()
				or not character.has_hideout()
			)
		)
	):
		set_aggressive(false)
		return
	var dtp = get_distance_to_character(character)
	var is_aggressive = is_aggressive()
	if is_aggressive and (dtp > TOO_FAR_RANGE or character.is_sprinting()):
		set_sprinting(true)
	if not is_aggressive \
		and dtp < AGGRESSION_RANGE \
		and not has_obstacles_between(character):
		set_aggressive(true)
		set_target_node(
			character.get_hideout()
				if character.is_hidden() # and character.has_hideout() -- was checked earlier
				else character
		)
		set_sprinting(true)
	elif is_aggressive and dtp > STOP_CHASING_RANGE:
		set_aggressive(false)
		set_sprinting(false)

func _physics_process(delta):
	if not game_state.is_level_ready():
		character_nodes.stop_all()
		return
	var d = .do_process(delta, false)
	if is_dying() or d.cannot_move:
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
