extends Spatial
onready var player = get_node("player")
onready var player_female = get_node("player_female")

func _ready():
	var is_loaded = game_params.finish_load()
	if not game_params.story_vars.is_game_start and not is_loaded:
		var player_basis = $PositionPlayer.get_transform().basis
		var player_origin = $PositionPlayer.get_transform().origin
		var companion_basis = $PositionCompanion.get_transform().basis
		var companion_origin = $PositionCompanion.get_transform().origin
		player.set_transform(Transform(player_basis, player_origin))
		player_female.set_transform(Transform(companion_basis, companion_origin))
	game_params.story_vars.is_game_start = false
	game_params.player_path = player.get_path()
	game_params.companion_path = player_female.get_path()
	var player_in_grass = $AreaGrass.overlaps_body(player)
	var female_in_grass = $AreaGrass.overlaps_body(player_female)
	player.set_sound_walk(player.SOUND_WALK_GRASS if player_in_grass else player.SOUND_WALK_SAND)
	game_params.change_music_to("underwater.ogg")
	player_female.set_sound_walk(player_female.SOUND_WALK_GRASS if female_in_grass else player_female.SOUND_WALK_SAND)
	if not is_loaded:
		game_params.autosave_create()

func _on_AreaGrass_body_entered(body):
	if body == player:
		player.set_sound_walk(player.SOUND_WALK_GRASS)
	if body == player_female:
		player_female.set_sound_walk(player_female.SOUND_WALK_GRASS)

func _on_AreaGrass_body_exited(body):
	if body == player:
		player.set_sound_walk(player.SOUND_WALK_SAND)
	if body == player_female:
		player_female.set_sound_walk(player_female.SOUND_WALK_SAND)