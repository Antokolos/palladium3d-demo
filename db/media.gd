extends Node
class_name PLDDBMedia

enum MusicId {
	NONE,
	LOADING,
	OUTSIDE,
	UNDERWATER,
	EXPLORE,
	DANGER,
	GAME_OVER,
	BEGINNING
}

const MUSIC = {
	MusicId.NONE : null,
	MusicId.LOADING : preload("res://music/loading.ogg"),
	MusicId.OUTSIDE : preload("res://music/outside.ogg"),
	MusicId.UNDERWATER : preload("res://music/underwater.ogg"),
	MusicId.EXPLORE : null,
	MusicId.DANGER : preload("res://music/sinkingisland.ogg"),
	MusicId.GAME_OVER : preload("res://music/bleeding_out2.ogg"),
	MusicId.BEGINNING : preload("res://music/bjs_forest.ogg")
}

enum SoundId {
	BRANCH_BREAKING,
	FIRE_LIGHTER,
	FIRE_EXTINGUISH,
	RAT_SQUEAK,
	OUCH_RU,
	OUCH_EN,
	BOTTLE_FILLING,
	MAN_DRINKS,
	MAN_DRINKS_ALT_RU,
	MAN_DRINKS_ALT_EN,
	FALLING_DOWN,
	MAN_BREATHE_IN_TANK,
	MAN_BREATHE_IN_1,
	MAN_BREATHE_IN_2,
	WOMAN_BREATHE_IN_1,
	WOMAN_BREATHE_IN_2,
	MAN_GETTING_HIT
}

const SOUND = {
	SoundId.BRANCH_BREAKING : preload("res://addons/palladium/assets/sound/environment/354095__bini-trns__seven-branches-are-breaking-short-close-up-h6.ogg"),
	SoundId.FIRE_LIGHTER : preload("res://addons/palladium/assets/sound/environment/238059__klankbeeld__cigarette-lighter-click-light-140320-0129.ogg"),
	SoundId.FIRE_EXTINGUISH : preload("res://addons/palladium/assets/sound/environment/155660__the-semen-incident__cig-extinguish_potuh_fakel.ogg"),
	SoundId.RAT_SQUEAK : preload("res://addons/palladium/assets/sound/environment/472399__joseagudelo__16-raton-chillando.ogg"),
	SoundId.OUCH_RU : preload("res://addons/palladium/assets/sound/environment/2334_oy.ogg"),
	SoundId.OUCH_EN : preload("res://addons/palladium/assets/sound/environment/2335_ouch.ogg"),
	SoundId.BOTTLE_FILLING : preload("res://addons/palladium/assets/sound/environment/bottle_filled.ogg"),
	SoundId.MAN_DRINKS : preload("res://addons/palladium/assets/sound/environment/2422_Andreas_drinks.ogg"),
	SoundId.MAN_DRINKS_ALT_RU : preload("res://addons/palladium/assets/sound/environment/2421_bandit_drinks.ogg"),
	SoundId.MAN_DRINKS_ALT_EN : preload("res://addons/palladium/assets/sound/environment/2421_bandit_drinks_eng.ogg"),
	SoundId.FALLING_DOWN : preload("res://addons/palladium/assets/sound/environment/417994__suburbanwizard__body-fall.ogg"),
	SoundId.MAN_BREATHE_IN_TANK : preload("res://addons/palladium/assets/sound/environment/2421_bandit_tank_sigh.ogg"),
	SoundId.MAN_BREATHE_IN_1 : preload("res://addons/palladium/assets/sound/environment/2419_bandit_sigh_1.ogg"),
	SoundId.MAN_BREATHE_IN_2 : preload("res://addons/palladium/assets/sound/environment/2420_bandit_sigh_2.ogg"),
	SoundId.WOMAN_BREATHE_IN_1 : preload("res://addons/palladium/assets/sound/environment/2402_enhale_1.ogg"),
	SoundId.WOMAN_BREATHE_IN_2 : preload("res://addons/palladium/assets/sound/environment/2402_enhale_2.ogg"),
	SoundId.MAN_GETTING_HIT : preload("res://addons/palladium/assets/sound/environment/163441__under7dude__man-getting-hit.ogg")
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
	if not common_utils.set_stream_loop(stream, is_loop):
		return
	sound_player.stream = stream
	sound_player.set_volume_db(volume_db)
	sound_player.play()

func stop_sound():
	sound_player.stop()

func stop_music():
	music_player.stop()
	music_ids = [ MusicId.NONE ]
