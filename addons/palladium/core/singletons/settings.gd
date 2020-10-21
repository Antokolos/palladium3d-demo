extends Node

signal language_changed(ID)
signal quality_changed(ID)
signal resolution_changed(ID)
signal cutoff_enabled_changed(enabled)
signal shader_cache_enabled_changed(enabled)

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

var tablet_orientation = TABLET_HORIZONTAL
var performance_stats = false
var cutoff_enabled = false
var shader_cache_enabled = true
var vsync = true
var fullscreen = true
var quality = QUALITY_OPT
var resolution = RESOLUTION_NATIVE
var aa_quality = AA_2X
var language = LANGUAGE_EN
var vlanguage = VLANGUAGE_RU
var subtitles = true
onready var master_bus_id = AudioServer.get_bus_index("Master")
onready var music_bus_id = AudioServer.get_bus_index("Music")
onready var sound_bus_id = AudioServer.get_bus_index("Sound")
onready var speech_bus_id = AudioServer.get_bus_index("Speech")
var master_volume = MASTER_VOLUME_DEFAULT
var music_volume = MUSIC_VOLUME_DEFAULT
var sound_volume = SOUND_VOLUME_DEFAULT
var speech_volume = SPEECH_VOLUME_DEFAULT

var resolutions = [
{
	"height" : 480
},
{
	"height" : 576
},
{
	"height" : 720
},
{
	"height" : 1080
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

	if ("performance_stats" in d):
		performance_stats = bool(d.performance_stats)

	if ("cutoff_enabled" in d):
		cutoff_enabled = bool(d.cutoff_enabled)

	if ("shader_cache_enabled" in d):
		shader_cache_enabled = bool(d.shader_cache_enabled)
	
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

	if ("subtitles" in d):
		subtitles = bool(d.subtitles)

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
		"performance_stats" : performance_stats,
		"cutoff_enabled" : cutoff_enabled,
		"shader_cache_enabled" : shader_cache_enabled,
		"vsync" : vsync,
		"fullscreen" : fullscreen,
		"quality" : quality,
		"resolution" : resolution,
		"aa_quality" : aa_quality,
		"language" : language,
		"vlanguage" : vlanguage,
		"subtitles" : subtitles,
		"master_volume" : master_volume,
		"music_volume" : music_volume,
		"sound_volume" : sound_volume,
		"speech_volume" : speech_volume
	}
	f.store_line( to_json(d) )

func set_language(lang_id):
	language = lang_id
	match lang_id:
		settings.LANGUAGE_RU:
			TranslationServer.set_locale("ru")
		_:
			TranslationServer.set_locale("en")
	emit_signal("language_changed", lang_id)

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

func set_cutoff_enabled(ce):
	cutoff_enabled = ce
	emit_signal("cutoff_enabled_changed", ce)

func set_shader_cache_enabled(sce):
	shader_cache_enabled = sce
	emit_signal("shader_cache_enabled_changed", sce)

func set_subtitles(s):
	subtitles = s

func need_subtitles():
	return subtitles or (vlanguage == VLANGUAGE_NONE)

func set_quality(ID):
	quality = ID
	emit_signal("quality_changed", ID)

func get_resolution_size(ID):
	var maxid = resolutions.size() - 1
	return OS.get_screen_size() if ID > maxid else \
				Vector2( OS.window_size.x * resolutions[ID].height / OS.window_size.y, resolutions[ID].height)

func set_resolution(ID):
	resolution = ID
	emit_signal("resolution_changed", ID)

func set_reverb(enable):
	AudioServer.set_bus_effect_enabled(sound_bus_id, 0, enable)
	AudioServer.set_bus_effect_enabled(speech_bus_id, 0, enable)

func _ready():
	load_settings()
	set_master_volume(master_volume)
	set_music_volume(music_volume)
	set_sound_volume(sound_volume)
	set_speech_volume(speech_volume)
	set_vsync(vsync)
	set_fullscreen(fullscreen)
	set_subtitles(subtitles)
	set_resolution(resolution)
