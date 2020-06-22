extends PLDCharacter
class_name PLDEnemy

const MAX_HITS = 3

var activated = false
var hits = 0

func _ready():
	pass

### Use target ###

func add_highlight(player_node):
	return "E: Hit" if activated else "E: Activate"

func remove_highlight(player_node):
	pass

func use(player_node):
	if not activated:
		activate()
	elif hits > MAX_HITS:
		take_damage(true)
	else:
		if fmod(hits, 2) == 0.0:
			is_sprinting = true
		take_damage(false)
		hits = hits + 1

func activate():
	hits = 0
	get_model().activate()
	$CutsceneTimer.start()
	activated = true

func get_preferred_target():
	return game_params.get_player() if activated else null

func is_enemy():
	return true

func attack():
	get_model().attack()

func take_damage(fatal):
	get_model().take_damage(fatal)
	if fatal:
		$Body_CollisionShape.disabled = true
		$Feet_CollisionShape.disabled = true
		$StandingArea/CollisionShape.disabled = true

func _on_CutsceneTimer_timeout():
	set_look_transition(true)

func _physics_process(delta):
	pass