extends Node

const AA_8X = 3
const AA_4X = 2
const AA_2X = 1
const AA_DISABLED = 0

const LANGUAGE_RU = 1
const LANGUAGE_EN = 0

const VLANGUAGE_EN = 2
const VLANGUAGE_RU = 1
const VLANGUAGE_NONE = 0

const MUSIC_VOLUME_DEFAULT = 50
const SOUND_VOLUME_DEFAULT = 100
const SPEECH_VOLUME_DEFAULT = 100

const QUALITY_HIGH = 3
const QUALITY_GOOD = 2
const QUALITY_OPT = 1
const QUALITY_NORM = 0

const RESOLUTION_NATIVE = 4
const RESOLUTION_1080 = 3
const RESOLUTION_720 = 2
const RESOLUTION_576 = 1
const RESOLUTION_480 = 0

const TABLET_HORIZONTAL = 1
const TABLET_VERTICAL = 0

var tablet_orientation = TABLET_VERTICAL
var vsync = true
var fullscreen = false
var quality = QUALITY_OPT
var resolution = RESOLUTION_NATIVE
var aa_quality = AA_2X
var language = LANGUAGE_EN
var vlanguage = VLANGUAGE_RU
onready var music_bus_id = AudioServer.get_bus_index("Music")
onready var sound_bus_id = AudioServer.get_bus_index("Sound")
onready var speech_bus_id = AudioServer.get_bus_index("Speech")
var music_volume = MUSIC_VOLUME_DEFAULT
var sound_volume = SOUND_VOLUME_DEFAULT
var speech_volume = SPEECH_VOLUME_DEFAULT

func load_settings():
	var f = File.new()
	var error = f.open("user://settings.json", File.READ)

	if (error):
		print("no settings to load.")
		return

	var d = parse_json( f.get_as_text() )
	if (typeof(d)!=TYPE_DICTIONARY):
		return

	if ("tablet_orientation" in d):
		tablet_orientation = int(d.tablet_orientation)

	if ("vsync" in d):
		vsync = bool(d.vsync)

	if ("fullscreen" in d):
		fullscreen = bool(d.fullscreen)

	if ("quality" in d):
		quality = int(d.quality)

	if ("resolution" in d):
		resolution = int(d.resolution)

	if ("aa_quality" in d):
		aa_quality = int(d.aa_quality)

	if ("language" in d):
		language = int(d.language)

	if ("vlanguage" in d):
		vlanguage = int(d.vlanguage)

	if ("music_volume" in d):
		music_volume = int(d.music_volume)

	if ("sound_volume" in d):
		sound_volume = int(d.sound_volume)

	if ("speech_volume" in d):
		speech_volume = int(d.speech_volume)

func save_settings():
	var f = File.new()
	var error = f.open("user://settings.json", File.WRITE)
	assert( not error )
	
	var d = {
		"tablet_orientation" : tablet_orientation,
		"vsync" : vsync,
		"fullscreen" : fullscreen,
		"quality" : quality,
		"resolution" : resolution,
		"aa_quality" : aa_quality,
		"language" : language,
		"vlanguage" : vlanguage,
		"music_volume" : music_volume,
		"sound_volume" : sound_volume,
		"speech_volume" : speech_volume
	}
	f.store_line( to_json(d) )

func set_volume(bus_id, level):
	# level in [0, 100] => volume from -30 dB to 0 dB
	var volume_db = 0.3 * level - 30
	if level > 0:
		AudioServer.set_bus_mute(bus_id, false)
		AudioServer.set_bus_volume_db(bus_id, volume_db)
	else:
		AudioServer.set_bus_mute(bus_id, true)

func set_music_volume(level):
	music_volume = level
	set_volume(music_bus_id, level)

func set_sound_volume(level):
	sound_volume = level
	set_volume(sound_bus_id, level)

func set_speech_volume(level):
	speech_volume = level
	set_volume(speech_bus_id, level)

func _ready():
	load_settings()
	set_music_volume(music_volume)
	set_sound_volume(sound_volume)
	set_speech_volume(speech_volume)