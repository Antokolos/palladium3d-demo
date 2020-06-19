extends PLDCharacter
class_name PLDEnemy

var activated = false

func _ready():
	pass

### Use target ###

func add_highlight(player_node):
	return "E: Disable" if activated else "E: Activate"

func remove_highlight(player_node):
	pass

func use(player_node):
	activate(not activated)

func activate(enable):
	get_model().activate(enable)
	activated = enable

func get_preferred_target():
	return game_params.get_player() if activated else null

func is_enemy():
	return true

func attack():
	get_model().attack()

func _on_CutsceneTimer_timeout():
	set_look_transition(true)

func _physics_process(delta):
	pass