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
		"vlanguage" : vlanguage
	}
	f.store_line( to_json(d) )

func _ready():
	load_settings()