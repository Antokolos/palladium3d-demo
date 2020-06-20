extends PLDCharacter
class_name PLDEnemy

const MAX_HITS = 3

var activated = false
var hits = 0

func _ready():
	pass

### Use target ###

func add_highlight(player_node):
	return "E: Disable" if activated else "E: Activate"

func remove_highlight(player_node):
	pass

func use(player_node):
	if not activated:
		activate(true)
	elif hits > MAX_HITS:
		die()
	else:
		take_damage()
		hits = hits + 1

func activate(enable):
	hits = 0
	get_model().activate(enable)
	$CutsceneTimer.start()
	activated = enable

func get_preferred_target():
	return game_params.get_player() if activated else null

func is_enemy():
	return true

func attack():
	get_model().attack()

func take_damage():
	get_model().take_damage()

func die():
	activate(false)
	get_model().ragdoll_start()

func _on_CutsceneTimer_timeout():
	set_look_transition(true)

func _physics_process(delta):
	pass