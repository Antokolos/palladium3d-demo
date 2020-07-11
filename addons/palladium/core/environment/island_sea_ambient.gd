extends Spatial

export var max_attenuation = 39
export var min_attenuation = 24
export var distance_to_shore = 116.1

onready var origin = get_global_transform().origin

func _ready():
	origin.y = 0
	set_attenuation(min_attenuation)

func set_attenuation(attenuation):
	$AudioStreamSea.set_volume_db(-attenuation)

func _process(delta):
	var player = game_params.get_player()
	if player:
		var player_origin = player.get_global_transform().origin
		player_origin.y = 0
		var dist = origin.distance_to(player_origin)
		if dist > distance_to_shore:
			set_attenuation(min_attenuation)
		else:
			var rel_dist = dist / distance_to_shore
			var attenuation = min_attenuation + (max_attenuation - min_attenuation) * (1.0 - rel_dist)
			set_attenuation(attenuation)