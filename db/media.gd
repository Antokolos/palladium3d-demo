extends Node
class_name PLDDBMedia

enum MusicId {NONE, LOADING, OUTSIDE, UNDERWATER, EXPLORE, DANGER}

const MUSIC = {
	MusicId.NONE : null,
	MusicId.LOADING : preload("res://music/loading.ogg"),
	MusicId.OUTSIDE : preload("res://music/outside.ogg"),
	MusicId.UNDERWATER : preload("res://music/underwater.ogg"),
	MusicId.EXPLORE : null,
	MusicId.DANGER : preload("res://music/sinkingisland.ogg")
}

enum SoundId {
	BRANCH_BREAKING,
	FIRE_LIGHTER,
	FIRE_EXTINGUISH,
	RAT_SQUEAK
}

const SOUND = {
	SoundId.BRANCH_BREAKING : preload("res://addons/palladium/assets/sound/environment/354095__bini-trns__seven-branches-are-breaking-short-close-up-h6.ogg"),
	SoundId.FIRE_LIGHTER : preload("res://addons/palladium/assets/sound/environment/238059__klankbeeld__cigarette-lighter-click-light-140320-0129.ogg"),
	SoundId.FIRE_EXTINGUISH : preload("res://addons/palladium/assets/sound/environment/155660__the-semen-incident__cig-extinguish_potuh_fakel.ogg"),
	SoundId.RAT_SQUEAK : preload("res://addons/palladium/assets/sound/environment/472399__joseagudelo__16-raton-chillando.ogg"),
}

onready var music_player = $MusicPlayer
onready var sound_player = $SoundPlayer
var music_ids = [ MusicId.NONE ]

func change_music_to(music_id, replace_existing = true):
	if music_ids[0] == music_id and not replace_existing:
		return
	if replace_existing:
		music_ids[0] = music_id
	else:
		music_ids.push_front(music_id)
	if music_id == MEDIA.MusicId.NONE or not MUSIC[music_id]:
		music_player.stream = null
		stop_music()
	else:
		music_player.stream = MUSIC[music_id]
		music_player.play()

func restore_music_from(music_id):
	if music_ids.size() > 1 and music_ids[0] == music_id:
		music_ids.pop_front()
		change_music_to(music_ids[0])

func play_sound(sound_id, is_loop = false, volume_db = 0):
	var stream = SOUND[sound_id]
	if stream is AudioStreamOGGVorbis:
		stream.set_loop(is_loop)
	elif stream is AudioStreamSample:
		stream.set_loop_mode(AudioStreamSample.LoopMode.LOOP_FORWARD if is_loop else AudioStreamSample.LoopMode.LOOP_DISABLED)
	sound_player.stream = stream
	sound_player.set_volume_db(volume_db)
	sound_player.play()

func stop_sound():
	sound_player.stop()

func stop_music():
	music_player.stop()
	music_ids = [ MusicId.NONE ]
