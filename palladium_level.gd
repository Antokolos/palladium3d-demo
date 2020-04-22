extends Navigation
class_name PalladiumLevel

export var is_inside = true
export var is_loadable = true
export var player_path = "player"
export var player_female_path = "player_female"
export var player_bandit_path = "player_bandit"

onready var player = get_node(player_path) if has_node(player_path) else null
onready var player_female = get_node(player_female_path) if has_node(player_female_path) else null
onready var player_bandit = get_node(player_bandit_path) if has_node(player_bandit_path) else null

func _ready():
	if not is_loadable:
		do_init(false)
		return
	var is_loaded = game_params.finish_load()
	do_init(is_loaded)
	if not is_loaded:
		game_params.autosave_create()

func do_init(is_loaded):
	# Override in children instead of _ready()
	pass

func is_inside():
	return is_inside