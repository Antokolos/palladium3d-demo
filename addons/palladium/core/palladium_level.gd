extends Navigation
class_name PLDLevel

export var is_bright = false
export var is_inside = true
export var is_loadable = true
export var player_path = "player"
export var player_female_path = "player_female"
export var player_bandit_path = "player_bandit"

onready var player = get_node(player_path) if has_node(player_path) else null
onready var player_female = get_node(player_female_path) if has_node(player_female_path) else null
onready var player_bandit = get_node(player_bandit_path) if has_node(player_bandit_path) else null

func _ready():
	settings.set_reverb(is_inside)
	if not is_loadable:
		do_init(false)
		restore_state()
		return
	var is_loaded = game_state.finish_load()
	do_init(is_loaded)
	restore_state()
	if not is_loaded:
		game_state.autosave_create()

func restore_state():
	# Should restore state of all activatables before other restorable_state nodes
	get_tree().call_group("activatables", "restore_state")
	get_tree().call_group("restorable_state", "restore_state")

func do_init(is_loaded):
	# Override in children instead of _ready()
	pass

func is_bright():
	return is_bright

func is_inside():
	return is_inside