extends Area
class_name PLDMusicArea

const MAX_ATTENUATION_DB = 40

export(AudioStream) var audio_stream = null
export(float) var fade_in_time_sec = 2.1
export(float) var fade_out_time_sec = 2.1
export(bool) var stop_music_on_exit = true
export(PLDDBMedia.MusicId) var music_id_on_exit = PLDDBMedia.MusicId.NONE

onready var music_player = $MusicPlayer
onready var fade_in_tween = $FadeInTween
onready var fade_out_tween = $FadeOutTween

func _ready():
	music_player.stream = audio_stream

func need_fade_in():
	return fade_in_time_sec > 0.0

func need_fade_out():
	return stop_music_on_exit and fade_out_time_sec > 0.0

func check_constraints_and_stop_tweens(body, music_constraint):
	if (
		not audio_stream
		or not body.is_in_group("party")
		or not body.is_player()
		or (
			music_constraint
			and not fade_in_tween.is_active()
			and not fade_out_tween.is_active()
		)
	):
		return false
	if fade_in_tween.is_active():
		fade_in_tween.stop_all()
	if fade_out_tween.is_active():
		fade_out_tween.stop_all()
	return true

func _on_music_area_body_entered(body):
	if not check_constraints_and_stop_tweens(body, music_player.is_playing()):
		return
	if music_id_on_exit == PLDDBMedia.MusicId.NONE:
		MEDIA.pause_music()
	else:
		MEDIA.stop_music()
	if need_fade_in():
		music_player.volume_db = -MAX_ATTENUATION_DB
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
	else:
		music_player.volume_db = 0
	music_player.play()

func _on_music_area_body_exited(body):
	if not check_constraints_and_stop_tweens(
		body,
		not stop_music_on_exit or not music_player.is_playing()
	):
		return
	if need_fade_out():
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
	else:
		music_player.stop()
		music_player.volume_db = -MAX_ATTENUATION_DB

func _on_FadeOutTween_tween_completed(object, key):
	music_player.stop()
	music_player.volume_db = -MAX_ATTENUATION_DB

func _on_FadeInTween_tween_completed(object, key):
	pass

func _on_MusicPlayer_finished():
	if music_id_on_exit == PLDDBMedia.MusicId.NONE:
		MEDIA.play_music()
	else:
		MEDIA.change_music_to(music_id_on_exit)
