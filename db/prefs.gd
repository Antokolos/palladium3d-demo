extends Node

### COMMON PART ###
const MODIFICATION_ID_DEFAULT = "DEFAULT"
const CLEAR_ON_SERVER_IF_NOT_IN_PREFS = false

var achievements = {}

func _ready():
	load_prefs()
	resend_achievements()

func clear_all_achievements():
	achievements.clear()
	for achievement_id in ACHIEVEMENTS_DATA.keys():
		if CLEAR_ON_SERVER_IF_NOT_IN_PREFS:
			common_utils.clear_achievement(achievement_id, false)
		achievements[achievement_id] = {}
	if CLEAR_ON_SERVER_IF_NOT_IN_PREFS:
		common_utils.store_stats()

func set_achievement(achievement_id, modification_id = MODIFICATION_ID_DEFAULT):
	if not achievements.has(achievement_id):
		push_warning("Cannot set achievement %d: key not found")
		return
	if not achievements[achievement_id].has(modification_id):
		achievements[achievement_id][modification_id] = 1
	else:
		achievements[achievement_id][modification_id] += 1
	store_achievement(achievement_id)
	# TODO: PERFECT_GAME_ACHIEVEMENT_ID
	save_prefs()

func store_achievement(achievement_id):
	if not achievements.has(achievement_id):
		push_warning("Cannot store achievement %d: key not found")
		return
	if not ACHIEVEMENTS_DATA[achievement_id].has("stat_id"):
		common_utils.set_achievement(achievement_id)
	else:
		var stat_id = ACHIEVEMENTS_DATA[achievement_id]["stat_id"]
		var stat_max = STATS_DATA[stat_id]["stat_max"]
		var l = achievements[achievement_id].size()
		common_utils.set_achievement_progress(achievement_id, l, stat_max)
		common_utils.set_stat_int(stat_id, l)
		if l >= stat_max:
			common_utils.set_achievement(achievement_id)

func get_achievement(achievement_id, modification_id = null):
	if not achievements.has(achievement_id):
		push_warning("Cannot get achievement %d: achievement key not found")
		return 0
	if not modification_id:
		return achievements[achievement_id].size()
	if not achievements[achievement_id].has(modification_id):
		return 0
	return achievements[achievement_id][modification_id]

func resend_achievements():
	for achievement_id in achievements.keys():
		if achievements[achievement_id].size() > 0:
			store_achievement(achievement_id)

func load_prefs():
	var f = File.new()
	var error = f.open("user://prefs.json", File.READ)

	if (error):
		print("no prefs to load.")
		clear_all_achievements()
		return

	var d = parse_json( f.get_as_text() )
	if (typeof(d)!=TYPE_DICTIONARY):
		return

	if ("achievements" in d):
		achievements = d.achievements
	else:
		clear_all_achievements()

func save_prefs():
	var f = File.new()
	var error = f.open("user://prefs.json", File.WRITE)
	assert( not error )
	
	var d = {
		"achievements" : achievements
	}
	f.store_line( to_json(d) )

### GAME-SPECIFIC PART ###

const STATS_DATA = {
	"STAT_GREEK_LANGUAGE_LOVER" : {"stat_min" : 0, "stat_max" : 11}
}

const ACHIEVEMENTS_DATA = {
	"MAIN_MENU" : {},
	"ATTENTIVENESS" : {},
	"CAREFULNESS" : {},
	"ANXIETY" : {},
	"ERIS" : {},
	"APATE" : {},
	"ARES" : {},
	"HERMES" : {},
	"ARTEMIS" : {},
	"HEBE" : {},
	"APHRODITE" : {},
	"APOLLO" : {},
	"HERA" : {},
	"LABYRINTH_EXPLORER" : {},
	"KNOWLEDGE_IS_POWER" : {},
	"POWER_OF_PROGRESS" : {},
	"SELF_CONFIDENCE" : {},
	"ANDREAS_AND_THE_CHAMBER_OF_SECRETS" : {},
	"A_STRANGE_SPRING" : {},
	"ANCIENT_ARTIFACT" : {},
	"ANCIENT_TREASURE" : {},
	"GOLD_DIGGER" : {},
	"MINOTAUR_MENACE" : {},
	"STEALTH_MASTER" : {},
	"MEDUSA_GAZE" : {},
	"BEVERAGE_OF_THE_GODS" : {},
	"COBWEB" : {},
	"SPIDER" : {},
	"MINOTAUR_CULT" : {},
	"RED_HERRING" : {},
	"DANGEROUS_MEDUSA" : {},
	"MEDUSA_SECRET" : {},
	"FEEBLE_MINDEDNESS_AND_COURAGE" : {},
	"BAD_MUSICIAN" : {},
	"RAT_TERROR" : {},
	"TAMER" : {},
	"GIFT_OF_THE_ANCIENTS" : {},
	"THE_CUP_OF_HEBE" : {},
	"BAD_SHOT" : {},
	"GREEK_LANGUAGE_LOVER" : {
		"stat_id" : "STAT_GREEK_LANGUAGE_LOVER"
	},
	"ALL_ENDINGS" : {}
}

const PERFECT_GAME_ACHIEVEMENT_ID = "ALL_ENDINGS"
