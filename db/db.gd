extends Node

const HEALING_RATE = 1
const MAX_QUICK_ITEMS = 6
const SCENE_PATH_DEFAULT = "res://forest.tscn"
const PLAYER_HEALTH_CURRENT_DEFAULT = 100
const PLAYER_HEALTH_MAX_DEFAULT = 100
const SUFFOCATION_DAMAGE_RATE = 10
const PLAYER_OXYGEN_CURRENT_DEFAULT = 100
const PLAYER_OXYGEN_MAX_DEFAULT = 100
const FATHER_NAME_HINT = "father"
const PLAYER_NAME_HINT = "player"
const FEMALE_NAME_HINT = "female"
const BANDIT_NAME_HINT = "bandit"
const SKELETON_NAME_HINT = "skeleton"
const PARTY_DEFAULT = {
	FATHER_NAME_HINT : false,
	PLAYER_NAME_HINT : true,
	FEMALE_NAME_HINT : false,
	BANDIT_NAME_HINT : false
}
const UNDERWATER_DEFAULT = {
	PLAYER_NAME_HINT : false,
	FEMALE_NAME_HINT : false,
	BANDIT_NAME_HINT : false
}
const STORY_VARS_DEFAULT = {
	"is_game_start" : true,
	"flashlight_on" : false,
	"in_lyre_area" : false,
	"apata_chest_rigid" : 0,
	"relationship_female" : 0,
	"relationship_bandit" : 0,
	"apata_trap_stage" : PLDGameState.TrapStages.ARMED,
	"erida_trap_stage" : PLDGameState.TrapStages.ARMED
}

enum LightIds {
	NONE = 0,
	APOLLO_1 = 10,
	APOLLO_2 = 20,
	APOLLO_3 = 30,
	APOLLO_4 = 40,
	APOLLO_5 = 50,
	APOLLO_6 = 60
}

enum RiddleIds {
	NONE = 0,
	HEBE_BUTTONS = 10,
	PLANETS = 20
}

enum PedestalIds {
	NONE = 0,
	APATA = 10,
	MUSES = 20,
	ERIDA_LOCK = 30,
	DEMO_HERMES = 40,
	DEMO_ARES = 50,
	HEBE_LOCK = 60,
	APHRODITE_LOCK = 70,
	HERA_LOCK = 80,
	ARTEMIS_LOCK = 90,
	APOLLO_LOCK = 100,
	HERMES_FLAT = 110,
	ERIS_FLAT = 120,
	ARES_FLAT = 130,
	HEBE_FLAT = 140,
	SWORD = 150,
	ARTEMIS_TRAP = 160,
	ARTEMIS_APHRODITE = 160,
	APOLLO_STATUE = 170,
	ARGUS_HERMES = 180
}

enum ContainerIds {
	NONE = 0,
	APATA_CHEST = 10
}

enum DoorIds {
	NONE = 0,
	APATA_TRAP_INNER = 10,
	APATA_SAVE_INNER = 20,
	APATA_SAVE_OUTER = 30,
	ERIDA_TRAP_INNER = 40,
	DEMO_FINISH = 50
}

enum ButtonActivatorIds {
	NONE = 0,
	ERIDA = 10,
	RIDDLE_BUTTON = 20,
	POMEGRANATE_1 = 30,
	POMEGRANATE_2 = 40,
	POMEGRANATE_3 = 50,
	POMEGRANATE_4 = 60,
	POMEGRANATE_5 = 70,
	POMEGRANATE_6 = 80,
}

enum TakableIds {
	NONE = 0,
	BUN = 2,
	ISLAND_MAP = 4,
	ISLAND_MAP_2 = 6,
	APATA = 10,
	URANIA = 20,
	CLIO = 30,
	MELPOMENE = 40,
	ARES = 50,
	HERMES = 60,
	ERIDA = 70,
	ARTEMIDA = 80,
	APHRODITE = 90,
	HEBE = 100,
	HERA = 110,
	APOLLO = 120,
	ATHENA = 130,
	SPHERE_FOR_POSTAMENT = 140,
	ENVELOPE = 150,
	BARN_LOCK_KEY = 160,
	GREEK_SWORD = 170,
	LYRE_SNAKE = 180,
	LYRE_RAT = 190,
	LYRE_SPIDER = 200,
	ARGUS_EYES = 210,
	GREEK_ARROW = 220,
	APPLE_JAR_GG = 230,
	APPLE_JAR_GS = 240,
	APPLE_JAR_SS = 250,
	APPLE_GOLD = 260,
	APPLE_SILVER = 270
}

const INVENTORY_DEFAULT = []
const QUICK_ITEMS_DEFAULT = [
	{ "item_id" : TakableIds.ISLAND_MAP, "count" : 1 },
	{ "item_id" : TakableIds.BUN, "count" : 1 }
]

const ITEMS = {
	TakableIds.BUN : { "item_nam" : "saffron_bun", "item_image" : "saffron_bun.png", "model_path" : "res://assets/bun.escn", "can_give" : true, "custom_actions" : ["item_preview_action_1"] },
	TakableIds.ISLAND_MAP : { "item_nam" : "island_map", "item_image" : "island_child.png", "model_path" : "res://assets/island_map.escn", "can_give" : false, "custom_actions" : [] },
	TakableIds.ENVELOPE : { "item_nam" : "envelope", "item_image" : "envelope.png", "model_path" : "res://assets/envelope.escn", "can_give" : false, "custom_actions" : ["item_preview_action_1"] },
	TakableIds.ISLAND_MAP_2 : { "item_nam" : "island_map_2", "item_image" : "island_father.png", "model_path" : "res://assets/island_map_2.escn", "can_give" : false, "custom_actions" : [] },
	TakableIds.BARN_LOCK_KEY : { "item_nam" : "barn_lock_key", "item_image" : "key.png", "model_path" : "res://assets/barn_lock_key.escn", "can_give" : false, "custom_actions" : [] },
	TakableIds.APATA : { "item_nam" : "statue_apata", "item_image" : "statue_apata.png", "model_path" : "res://assets/statue_4.escn", "can_give" : false, "custom_actions" : [] },
	TakableIds.CLIO : { "item_nam" : "statue_clio", "item_image" : "statue_clio.png", "model_path" : "res://assets/statue_2.escn", "can_give" : false, "custom_actions" : [] },
	TakableIds.MELPOMENE : { "item_nam" : "statue_melpomene", "item_image" : "statue_melpomene.png", "model_path" : "res://assets/statue_3.escn", "can_give" : false, "custom_actions" : [] },
	TakableIds.URANIA : { "item_nam" : "statue_urania", "item_image" : "statue_urania.png", "model_path" : "res://assets/statue_1.escn", "can_give" : false, "custom_actions" : [] },
	TakableIds.HERMES : { "item_nam" : "statue_hermes", "item_image" : "statue_hermes.png", "model_path" : "res://assets/statue_hermes.escn", "can_give" : false, "custom_actions" : [] },
	TakableIds.SPHERE_FOR_POSTAMENT : { "item_nam" : "sphere_for_postament_body", "item_image" : "sphere.png", "model_path" : "res://assets/sphere_for_postament.escn", "can_give" : false, "custom_actions" : [] },
	TakableIds.ARES : { "item_nam" : "statue_ares", "item_image" : "statue_ares.png", "model_path" : "res://assets/statue_ares.escn", "can_give" : false, "custom_actions" : [] },
	TakableIds.ERIDA : { "item_nam" : "statue_erida", "item_image" : "statue_erida.png", "model_path" : "res://assets/statue_erida.escn", "can_give" : false, "custom_actions" : [] },
	TakableIds.ARTEMIDA : { "item_nam" : "statue_artemida", "item_image" : "statue_artemis.png", "model_path" : "res://assets/statue_artemida.escn", "can_give" : false, "custom_actions" : [] },
	TakableIds.APHRODITE : { "item_nam" : "statue_aphrodite", "item_image" : "statue_aphrodite.png", "model_path" : "res://assets/statue_aphrodite.escn", "can_give" : false, "custom_actions" : [] },
	TakableIds.HEBE : { "item_nam" : "statue_hebe", "item_image" : "statue_hebe.png", "model_path" : "res://assets/statue_hebe.escn", "can_give" : false, "custom_actions" : [] },
	TakableIds.HERA : { "item_nam" : "hera_statue", "item_image" : "statue_hera.png", "model_path" : "res://assets/hera_statue.escn", "can_give" : false, "custom_actions" : [] },
	TakableIds.APOLLO : { "item_nam" : "statue_apollo", "item_image" : "statue_apollo.png", "model_path" : "res://assets/statue_apollo.escn", "can_give" : false, "custom_actions" : [] },
	TakableIds.ATHENA : { "item_nam" : "statue_athena", "item_image" : "statue_athena.png", "model_path" : "res://assets/statue_athena.escn", "can_give" : false, "custom_actions" : [] },
	TakableIds.GREEK_SWORD : { "item_nam" : "sword_body", "item_image" : "saffron_bun.png", "model_path" : "res://assets/sword.escn", "can_give" : false, "custom_actions" : [] },
	TakableIds.LYRE_RAT : { "item_nam" : "lyre_rat", "item_image" : "saffron_bun.png", "model_path" : "res://assets/lyre_rat.escn", "can_give" : false, "custom_actions" : ["item_preview_action_1"] },
	TakableIds.LYRE_SNAKE : { "item_nam" : "lyre_snake", "item_image" : "saffron_bun.png", "model_path" : "res://assets/lyre_snake.escn", "can_give" : false, "custom_actions" : ["item_preview_action_1"] },
	TakableIds.LYRE_SPIDER : { "item_nam" : "lyre_spider", "item_image" : "saffron_bun.png", "model_path" : "res://assets/lyre_spider.escn", "can_give" : false, "custom_actions" : ["item_preview_action_1"] },
	TakableIds.ARGUS_EYES : { "item_nam" : "argus_eyes", "item_image" : "saffron_bun.png", "model_path" : "res://assets/argus_eyes_pile.escn", "can_give" : false, "custom_actions" : [] },
	TakableIds.GREEK_ARROW : { "item_nam" : "greek_arrow", "item_image" : "saffron_bun.png", "model_path" : "res://assets/greek_arrow.escn", "can_give" : false, "custom_actions" : [] },
	TakableIds.APPLE_JAR_GG : { "item_nam" : "apple_jar_gg", "item_image" : "saffron_bun.png", "model_path" : "res://assets/apple_jar.escn", "can_give" : false, "custom_actions" : [] },
	TakableIds.APPLE_JAR_GS : { "item_nam" : "apple_jar_gs", "item_image" : "saffron_bun.png", "model_path" : "res://assets/apple_jar.escn", "can_give" : false, "custom_actions" : [] },
	TakableIds.APPLE_JAR_SS : { "item_nam" : "apple_jar_ss", "item_image" : "saffron_bun.png", "model_path" : "res://assets/apple_jar.escn", "can_give" : false, "custom_actions" : [] },
	TakableIds.APPLE_GOLD : { "item_nam" : "apple_gold", "item_image" : "saffron_bun.png", "model_path" : "res://assets/apple.escn", "can_give" : false, "custom_actions" : [] },
	TakableIds.APPLE_SILVER : { "item_nam" : "apple_silver", "item_image" : "saffron_bun.png", "model_path" : "res://assets/apple.escn", "can_give" : false, "custom_actions" : [] },
}

static func lookup_takable_from_int(item_id : int):
	for takable_id in TakableIds:
		if item_id == TakableIds[takable_id]:
			return TakableIds[takable_id]
	return TakableIds.NONE

static func get_item_data(takable_id):
	if not takable_id or takable_id == TakableIds.NONE or not ITEMS.has(takable_id):
		return null
	return ITEMS[takable_id]

static func get_item_name(takable_id):
	var item_data = get_item_data(takable_id)
	return item_data.item_nam if item_data else null
