extends Navigation

onready var player = get_node("player")
onready var player_female = get_node("player_female")
var player_toggle_enable = true

func _ready():
	game_params.finish_load()
	game_params.player_path = player.get_path()
	game_params.companion_path = player_female.get_path()
	player.take("saffron_bun", "res://scenes/bun.tscn")
	player.set_sound_walk($player.SOUND_WALK_CONCRETE)
	player_female.set_sound_walk($player_female.SOUND_WALK_CONCRETE)

func _unhandled_input(event):
	if not player_toggle_enable:
		return
	if event is InputEventKey:
		match event.scancode:
			KEY_9:
				player.become_player()
			KEY_0:
				player_female.become_player()
