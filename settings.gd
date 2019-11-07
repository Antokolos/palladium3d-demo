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

const MASTER_VOLUME_DEFAULT = 100
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
onready var master_bus_id = AudioServer.get_bus_index("Master")
onready var music_bus_id = AudioServer.get_bus_index("Music")
onready var sound_bus_id = AudioServer.get_bus_index("Sound")
onready var speech_bus_id = AudioServer.get_bus_index("Speech")
var master_volume = MASTER_VOLUME_DEFAULT
var music_volume = MUSIC_VOLUME_DEFAULT
var sound_volume = SOUND_VOLUME_DEFAULT
var speech_volume = SPEECH_VOLUME_DEFAULT

var available_resolutions = [
{
	"resolution_height" : 576,
	"default_font" : 14,
	"text_separation" : 3,
	"actorname_prev_font" : 10,
	"conversation_prev_font" : 10,
	"actorname_font" : 16,
	"conversation_font" : 16
},
{
	"resolution_height" : 720,
	"default_font" : 18,
	"text_separation" : 10,
	"actorname_prev_font" : 14,
	"conversation_prev_font" : 14,
	"actorname_font" : 20,
	"conversation_font" : 20
},
{
	"resolution_height" : 1080,
	"default_font" : 26,
	"text_separation" : 30,
	"actorname_prev_font" : 20,
	"conversation_prev_font" : 20,
	"actorname_font" : 30,
	"conversation_font" : 30
}
]

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

	if ("master_volume" in d):
		master_volume = int(d.master_volume)

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
		"master_volume" : master_volume,
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

func set_master_volume(level):
	master_volume = level
	set_volume(master_bus_id, level)

func set_music_volume(level):
	music_volume = level
	set_volume(music_bus_id, level)

func set_sound_volume(level):
	sound_volume = level
	set_volume(sound_bus_id, level)

func set_speech_volume(level):
	speech_volume = level
	set_volume(speech_bus_id, level)

func set_vsync(vs):
	OS.set_use_vsync(vs)
	vsync = vs

func set_fullscreen(fs):
	OS.set_window_fullscreen(fs)
	fullscreen = fs

func set_resolution(ID):
	var maxid = available_resolutions.size() - 1
	if ID > maxid:
		var ssize = OS.get_screen_size()
		get_tree().get_root().set_size_override(true, ssize)
		get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_VIEWPORT, SceneTree.STRETCH_ASPECT_KEEP, ssize)
	else:
		var minsize=Vector2( OS.window_size.x * available_resolutions[ID].resolution_height / OS.window_size.y, available_resolutions[ID].resolution_height)
		get_tree().get_root().set_size_override(true, minsize)
		get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_VIEWPORT, SceneTree.STRETCH_ASPECT_KEEP_HEIGHT, minsize)
	resolution = ID

func _ready():
	load_settings()
	set_master_volume(master_volume)
	set_music_volume(music_volume)
	set_sound_volume(sound_volume)
	set_speech_volume(speech_volume)
	set_vsync(vsync)
	set_fullscreen(fullscreen)
	set_resolution(resolution)
