extends Area
class_name PLDMusicArea

const MAX_ATTENUATION_DB = 40

export var audio_stream : AudioStream = null
export var fade_in_time_sec : float = 2.1
export var fade_out_time_sec : float = 2.1

onready var music_player = $MusicPlayer
onready var fade_in_tween = $FadeInTween
onready var fade_out_tween = $FadeOutTween

func _ready():
	music_player.stream = audio_stream

func _on_music_area_body_entered(body):
	if (
		not audio_stream
		or music_player.is_playing()
		or not body.is_in_group("party")
		or not body.is_player()
	):
		return
	music_player.volume_db = -MAX_ATTENUATION_DB
	music_player.play()
	fade_in_tween.interpolate_property(
		music_player,
		"volume_db",
		-MAX_ATTENUATION_DB,
		0,
		fade_in_time_sec,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN_OUT
	)
	fade_in_tween.start()

func _on_music_area_body_exited(body):
	if (
		not audio_stream
		or not music_player.is_playing()
		or not body.is_in_group("party")
		or not body.is_player()
	):
		return
	fade_out_tween.interpolate_property(
		music_player,
		"volume_db",
		0,
		-MAX_ATTENUATION_DB,
		fade_out_time_sec,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN_OUT
	)
	fade_out_tween.start()

func _on_FadeOutTween_tween_completed(object, key):
	music_player.stop()
	music_player.volume_db = -MAX_ATTENUATION_DB

func _on_FadeInTween_tween_completed(object, key):
	pass # Replace with function body.
