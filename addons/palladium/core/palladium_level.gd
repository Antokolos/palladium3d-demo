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
		game_state.restore_states()
		do_init(false)
		game_state.set_level_ready(true)
		return
	var is_loaded = game_state.finish_load()
	do_init(is_loaded)
	if not is_loaded:
		game_state.autosave_create()
	game_state.set_level_ready(true)

func do_init(is_loaded):
	# Override in children instead of _ready()
	pass

func is_bright():
	return is_bright

func is_inside():
	return is_inside