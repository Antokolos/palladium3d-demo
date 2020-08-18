extends PLDCharacter
class_name PLDEnemy

signal attack_started(enemy, target)

const MAX_HITS = 3
const TOO_FAR_RANGE = 10
const AGGRESSION_RANGE = 11
const STOP_CHASING_RANGE = 12

var party_members_cache = []
var hits = 0

func _ready():
	get_tree().call_group("hideouts", "connect_signals", self)

func use_usable(player_node, usable):
	if not usable is PLDHideout:
		return
	set_sprinting(false)
	set_aggressive(false)
	character_nodes.stop_attack()

### Use target ###

func use(player_node, camera_node):
	if not is_activated():
		return false
	var u = .use(player_node, camera_node)
	if not u and can_be_attacked():
		hit(camera_node)
	return true

func add_highlight(player_node):
	if not is_activated() or is_dying():
		return ""
	var h = .add_highlight(player_node)
	if not h.empty():
		return h
	return "E: Shoot" if can_be_attacked() else ""

func hit(hit_direction_node):
	if not is_activated():
		return
	elif hits > MAX_HITS:
		take_damage(true, hit_direction_node)
	else:
		take_damage(false, hit_direction_node)
		hits = hits + 1

func activate():
	.activate()
	hits = 0
	set_sprinting(false)
	character_nodes.start_cutscene_timer()

func get_party_members():
	if party_members_cache.empty():
		party_members_cache = get_tree().get_nodes_in_group("party")
	return party_members_cache

func get_nearest_party_member():
	var party = get_party_members()
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

func take_damage(fatal, hit_direction_node):
	if not is_activated() or is_dying():
		return
	stop_cutscene()
	get_model().take_damage(fatal)
	push_back(get_push_vec(hit_direction_node))
	if fatal:
		$Body_CollisionShape.disabled = true
		$Feet_CollisionShape.disabled = false
		character_nodes.enable_areas(false)

func set_states(player):
	if player.is_hidden():
		set_sprinting(false)
		set_aggressive(false)
		return
	var dtp = get_distance_to_character(player)
	if is_aggressive() and (dtp > TOO_FAR_RANGE or player.is_sprinting()):
		set_sprinting(true)
	if dtp < AGGRESSION_RANGE:
		if not is_aggressive():
			# Run at the player when aggression was just triggered
			set_sprinting(true)
		set_aggressive(true)
	elif dtp > STOP_CHASING_RANGE:
		set_aggressive(false)
		set_sprinting(false)

func _physics_process(delta):
	.do_process(delta, false, false)
	if not is_activated():
		return
	set_states(get_nearest_party_member())
	if not is_aggressive():
		if not is_patrolling():
			set_sprinting(false)
			set_patrolling(true)
		return
	character_nodes.handle_attack()
