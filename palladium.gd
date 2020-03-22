extends Navigation

onready var player = get_node("player")
onready var player_female = get_node("player_female")
onready var player_bandit = get_node("player_bandit")
var player_toggle_enable = true

func _ready():
	var is_loaded = game_params.finish_load()
	game_params.stop_music()
	player.set_sound_walk($player.SOUND_WALK_CONCRETE)
	player_female.set_sound_walk($player_female.SOUND_WALK_CONCRETE)
	player_bandit.set_sound_walk($player_female.SOUND_WALK_CONCRETE)
	if not conversation_manager.conversation_is_in_progress("004_TorchesIgnition") and conversation_manager.conversation_is_not_finished(player, "004_TorchesIgnition"):
		get_tree().call_group("torches", "enable", false, false)
	if not is_loaded:
		game_params.autosave_create()

func _unhandled_input(event):
	if not player_toggle_enable:
		return
	if event is InputEventKey:
		match event.scancode:
			KEY_9:
				player.become_player()
			KEY_0:
				player_female.become_player()
