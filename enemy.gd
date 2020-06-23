extends PLDCharacter
class_name PLDEnemy

const MAX_HITS = 3
const TOO_FAR_RANGE = 10

var activated = false
var hits = 0

func _ready():
	pass

### Use target ###

func add_highlight(player_node):
	return "E: Hit" if activated else "E: Activate"

func remove_highlight(player_node):
	pass

func use(player_node, camera_node):
	if not activated:
		activate()
	elif hits > MAX_HITS:
		take_damage(true, camera_node)
	else:
#		if fmod(hits, 2) == 0.0:
#			is_sprinting = true
		take_damage(false, camera_node)
		hits = hits + 1

func activate():
	hits = 0
	is_sprinting = false
	get_model().activate()
	$CutsceneTimer.start()
	activated = true

func get_preferred_target():
	return game_params.get_player() if activated else null

func is_enemy():
	return true

func attack():
	is_sprinting = false
	get_model().attack()

func take_damage(fatal, camera_node):
	stop_cutscene()
	get_model().take_damage(fatal)
	push_back(get_push_vec(camera_node))
	if fatal:
		$Body_CollisionShape.disabled = true
		$Feet_CollisionShape.disabled = false
		$StandingArea/CollisionShape.disabled = true

func _on_CutsceneTimer_timeout():
	set_look_transition(true)

func _physics_process(delta):
	if not is_sprinting and get_distance_to_target() > TOO_FAR_RANGE:
		is_sprinting = true