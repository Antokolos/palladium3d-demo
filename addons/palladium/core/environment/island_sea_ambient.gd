extends Spatial

export var max_attenuation = 55
export var min_attenuation = 24
export var distance_to_shore = 116.1

onready var origin = get_global_transform().origin

func _ready():
	origin.y = 0
	set_attenuation(min_attenuation, max_attenuation)

func set_attenuation(attenuation_sea, attenuation_wind):
	$AudioStreamSea.set_volume_db(-attenuation_sea)
	$AudioStreamWind.set_volume_db(-attenuation_wind)

func _process(delta):
	if not game_state.is_level_ready():
		return
	var player = game_state.get_player()
	if player:
		var player_origin = player.get_global_transform().origin
		player_origin.y = 0
		var dist = origin.distance_to(player_origin)
		if dist > distance_to_shore:
			set_attenuation(min_attenuation, max_attenuation)
		else:
			var rel_dist = dist / distance_to_shore
			var attenuation_sea = min_attenuation + (max_attenuation - min_attenuation) * (1.0 - rel_dist)
			var attenuation_wind = min_attenuation + (max_attenuation - min_attenuation) * rel_dist
			set_attenuation(attenuation_sea, attenuation_wind)