extends Node

enum MusicId {NONE, LOADING, OUTSIDE, UNDERWATER, EXPLORE, DANGER}
const MUSIC = {
	MusicId.NONE : null,
	MusicId.LOADING : preload("res://music/loading.ogg"),
	MusicId.OUTSIDE : preload("res://music/outside.ogg"),
	MusicId.UNDERWATER : preload("res://music/underwater.ogg"),
	MusicId.EXPLORE : null,
	MusicId.DANGER : preload("res://music/sinkingisland.ogg")
}

enum SoundId {LYRE_CORRECT, LYRE_WRONG, SNAKE_HISS}
const SOUND = {
	SoundId.LYRE_CORRECT : preload("res://sound/environment/Apollo_lyre_good_2.ogg"),
	SoundId.LYRE_WRONG : preload("res://sound/environment/Apollo_bad_lyre_sound.ogg"),
	SoundId.SNAKE_HISS : preload("res://sound/environment/Labyrinth_snake_hiss.ogg")
}

var music_ids = [ MusicId.NONE ]

func change_music_to(music_id, replace_existing = true):
	if music_ids[0] == music_id and not replace_existing:
		return
	if replace_existing:
		music_ids[0] = music_id
	else:
		music_ids.push_front(music_id)
	if music_id == MEDIA.MusicId.NONE or not MUSIC[music_id]:
		$MusicPlayer.stream = null
		stop_music()
	else:
		$MusicPlayer.stream = MUSIC[music_id]
		$MusicPlayer.play()

func restore_music_from(music_id):
	if music_ids.size() > 1 and music_ids[0] == music_id:
		music_ids.pop_front()
		change_music_to(music_ids[0])

func play_sound(sound_id, is_loop = false):
	var stream = SOUND[sound_id]
	if stream is AudioStreamOGGVorbis:
		stream.set_loop(is_loop)
	elif stream is AudioStreamSample:
		stream.set_loop_mode(AudioStreamSample.LoopMode.LOOP_FORWARD if is_loop else AudioStreamSample.LoopMode.LOOP_DISABLED)
	$SoundPlayer.stream = stream
	$SoundPlayer.play()

func stop_music():
	$MusicPlayer.stop()
	music_ids = [ MusicId.NONE ]
