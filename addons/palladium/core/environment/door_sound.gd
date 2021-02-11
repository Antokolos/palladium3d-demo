extends Spatial

onready var door_sound = get_node("door_sound")
onready var stop_sound = get_node("stop_sound")

export(AudioStream) var door_sound_stream = null
export(AudioStream) var stop_sound_stream = null
export var max_attenuation = 39
export var min_attenuation = 3
export var min_dist = 1
export var max_dist = 35

onready var origin = get_global_transform().origin
var is_closing = false

func _ready():
	origin.y = 0
	door_sound.stream = door_sound_stream
	stop_sound.stream = stop_sound_stream
	set_attenuation(min_attenuation)

func play(is_closing):
	self.is_closing = is_closing
	door_sound.play()

func set_attenuation(attenuation):
	door_sound.set_volume_db(-attenuation)
	stop_sound.set_volume_db(-attenuation)

func _physics_process(delta):
	var player = game_state.get_player()
	if not player:
		return
	var player_origin = player.get_global_transform().origin
	player_origin.y = 0
	var dist = origin.distance_to(player_origin)
	if dist > max_dist:
		set_attenuation(max_attenuation)
		return
	if dist < min_dist:
		set_attenuation(min_attenuation)
	else:
		var rel_dist = (dist - min_dist) / (max_dist - min_dist)
		var attenuation = min_attenuation + (max_attenuation - min_attenuation) * rel_dist
		set_attenuation(attenuation)

func _on_door_sound_finished():
	if is_closing:
		is_closing = false
		if stop_sound_stream:
			stop_sound.play()
