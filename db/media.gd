extends Node
class_name PLDDBMedia

signal music_finished()

enum MusicId {
	NONE = 0,
	LOADING = 10,
	OUTSIDE = 20,
	UNDERWATER = 30,
	EXPLORE = 40,
	DANGER = 50,
	GAME_OVER = 60,
	BEGINNING = 70,
	FINAL_TRAP = 130
}

const MUSIC = {
	MusicId.NONE : null,
	MusicId.LOADING : preload("res://music/loading.ogg"),
	MusicId.OUTSIDE : preload("res://music/outside.ogg"),
	MusicId.UNDERWATER : preload("res://music/underwater.ogg"),
	MusicId.EXPLORE : preload("res://music/dark-ambience-0.ogg"),
	MusicId.DANGER : preload("res://music/sinkingisland.ogg"),
	MusicId.GAME_OVER : preload("res://music/bleeding_out2.ogg"),
	MusicId.BEGINNING : preload("res://music/bjs_forest.ogg"),
	MusicId.FINAL_TRAP : preload("res://music/Watcher.ogg")
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
	MAN_GETTING_HIT,
	FEMALE_SCREAM_SHORT,
	MALE_SCREAM_SHORT
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
	SoundId.MAN_GETTING_HIT : preload("res://addons/palladium/assets/sound/environment/163441__under7dude__man-getting-hit.ogg"),
	SoundId.FEMALE_SCREAM_SHORT : preload("res://addons/palladium/assets/sound/environment/2604_A_a_h_last_trap.ogg"),
	SoundId.MALE_SCREAM_SHORT : preload("res://addons/palladium/assets/sound/environment/2336_mur_yelling.ogg")
}

onready var music_player = $MusicPlayer
onready var sound_players = get_node("sound_players").get_children()
onready var pre_delay_timers = get_node("pre_delay_timers").get_children()
var music_ids = [ MusicId.NONE ]
var music_paused = false

static func lookup_music_id_from_int(music_id : int):
	for id in MusicId:
		if music_id == MusicId[id]:
			return MusicId[id]
	return MusicId.NONE

static func lookup_music_ids_from_ints(music_ids : Array):
	var result = []
	for music_id in music_ids:
		result.append(lookup_music_id_from_int(music_id))
	return result

func change_music_to(music_id, replace_existing = true):
	var stream = MUSIC[music_id] if music_id != MEDIA.MusicId.NONE and MUSIC.has(music_id) else null
	if (
		music_ids[0] == music_id
		and stream and music_player.stream
		and common_utils.is_same_resource(stream, music_player.stream)
	):
		if not music_player.is_playing():
			play_music()
		return
	if replace_existing:
		music_ids[0] = music_id
	else:
		music_ids.push_front(music_id)
	if stream:
		music_player.stream = stream
		play_music()
	else:
		music_player.stream = null
		stop_music()

func restore_music_from_save(saved_music_ids):
	music_ids = (
		lookup_music_ids_from_ints(saved_music_ids)
			if saved_music_ids and not saved_music_ids.empty()
			else [ MusicId.NONE ]
	)
	change_music_to(music_ids[0])

func restore_music_from(music_id):
	if music_ids.size() > 1 and music_ids[0] == music_id:
		music_ids.pop_front()
		change_music_to(music_ids[0])

func play_sound(sound_id, is_loop = false, volume_db = 0, pre_delay_sec = 0.0, channel = -1):
	if channel < -1 or channel > sound_players.size():
		push_error("Incorrect channel number %d" % channel)
		return null
	var stream = SOUND[sound_id]
	if not common_utils.set_stream_loop(stream, is_loop):
		return null
	if channel >= 0:
		return play_stream(sound_players[channel], stream, volume_db, pre_delay_timers[channel], pre_delay_sec)
	else:
		for i in range(0, sound_players.size()):
			var sound_player = sound_players[i]
			var pre_delay_timer = pre_delay_timers[i]
			if not sound_player.is_playing() and pre_delay_timer.is_stopped():
				return play_stream(sound_player, stream, volume_db, pre_delay_timer, pre_delay_sec)

func play_stream(sound_player, stream, volume_db, pre_delay_timer, pre_delay_sec):
	if pre_delay_sec > 0.0:
		pre_delay_timer.start(pre_delay_sec)
		yield(pre_delay_timer, "timeout")
	sound_player.stream = stream
	sound_player.set_volume_db(volume_db)
	sound_player.play()
	return sound_player

func stop_sound():
	for sound_player in sound_players:
		sound_player.stop()

func play_music():
	if music_player.stream:
		music_player.play()
	music_paused = false

func pause_music():
	music_paused = true
	music_player.stop()

func stop_music():
	music_player.stop()
	music_ids = [ MusicId.NONE ]

func _on_MusicPlayer_finished():
	emit_signal("music_finished")
	if (
		not music_paused
		and not music_ids.empty()
		and music_ids[0] != MusicId.NONE
		and music_player.stream
		and common_utils.is_same_resource(music_player.stream, MUSIC[music_ids[0]])
	):
		music_ids.pop_front()
		if music_ids.empty():
			music_ids = [ MusicId.NONE ]
		else:
			change_music_to(music_ids[0])
