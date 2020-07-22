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
	"apata_trap_stage" : PLDGameParams.TrapStages.ARMED,
	"erida_trap_stage" : PLDGameParams.TrapStages.ARMED
}
const INVENTORY_DEFAULT = []
const QUICK_ITEMS_DEFAULT = [
	{ "nam" : "island_map", "count" : 1 },
	{ "nam" : "saffron_bun", "count" : 1 }
]

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
	APPLE_JAR_SS = 250
}

const ITEMS = {
	"saffron_bun" : { "item_image" : "saffron_bun.png", "model_path" : "res://assets/bun.escn", "can_give" : true, "custom_actions" : ["item_preview_action_1"] },
	"island_map" : { "item_image" : "island_child.png", "model_path" : "res://assets/island_map.escn", "can_give" : false, "custom_actions" : [] },
	"envelope" : { "item_image" : "envelope.png", "model_path" : "res://assets/envelope.escn", "can_give" : false, "custom_actions" : ["item_preview_action_1"] },
	"island_map_2" : { "item_image" : "island_father.png", "model_path" : "res://assets/island_map_2.escn", "can_give" : false, "custom_actions" : [] },
	"barn_lock_key" : { "item_image" : "key.png", "model_path" : "res://assets/barn_lock_key.escn", "can_give" : false, "custom_actions" : [] },
	"statue_apata" : { "item_image" : "statue_apata.png", "model_path" : "res://assets/statue_4.escn", "can_give" : false, "custom_actions" : [] },
	"statue_clio" : { "item_image" : "statue_clio.png", "model_path" : "res://assets/statue_2.escn", "can_give" : false, "custom_actions" : [] },
	"statue_melpomene" : { "item_image" : "statue_melpomene.png", "model_path" : "res://assets/statue_3.escn", "can_give" : false, "custom_actions" : [] },
	"statue_urania" : { "item_image" : "statue_urania.png", "model_path" : "res://assets/statue_1.escn", "can_give" : false, "custom_actions" : [] },
	"statue_hermes" : { "item_image" : "statue_hermes.png", "model_path" : "res://assets/statue_hermes.escn", "can_give" : false, "custom_actions" : [] },
	"sphere_for_postament_body" : { "item_image" : "sphere.png", "model_path" : "res://assets/sphere_for_postament.escn", "can_give" : false, "custom_actions" : [] },
	"statue_ares" : { "item_image" : "statue_ares.png", "model_path" : "res://assets/statue_ares.escn", "can_give" : false, "custom_actions" : [] },
	"statue_erida" : { "item_image" : "statue_erida.png", "model_path" : "res://assets/statue_erida.escn", "can_give" : false, "custom_actions" : [] },
	"statue_artemida" : { "item_image" : "statue_artemis.png", "model_path" : "res://assets/statue_artemida.escn", "can_give" : false, "custom_actions" : [] },
	"statue_aphrodite" : { "item_image" : "statue_aphrodite.png", "model_path" : "res://assets/statue_aphrodite.escn", "can_give" : false, "custom_actions" : [] },
	"statue_hebe" : { "item_image" : "statue_hebe.png", "model_path" : "res://assets/statue_hebe.escn", "can_give" : false, "custom_actions" : [] },
	"hera_statue" : { "item_image" : "statue_hera.png", "model_path" : "res://assets/hera_statue.escn", "can_give" : false, "custom_actions" : [] },
	"statue_apollo" : { "item_image" : "statue_apollo.png", "model_path" : "res://assets/statue_apollo.escn", "can_give" : false, "custom_actions" : [] },
	"statue_athena" : { "item_image" : "statue_athena.png", "model_path" : "res://assets/statue_athena.escn", "can_give" : false, "custom_actions" : [] },
	"sword_body" : { "item_image" : "saffron_bun.png", "model_path" : "res://assets/sword.escn", "can_give" : false, "custom_actions" : [] },
	"lyre_rat" : { "item_image" : "saffron_bun.png", "model_path" : "res://assets/lyre_rat.escn", "can_give" : false, "custom_actions" : ["item_preview_action_1"] },
	"lyre_snake" : { "item_image" : "saffron_bun.png", "model_path" : "res://assets/lyre_snake.escn", "can_give" : false, "custom_actions" : ["item_preview_action_1"] },
	"lyre_spider" : { "item_image" : "saffron_bun.png", "model_path" : "res://assets/lyre_spider.escn", "can_give" : false, "custom_actions" : ["item_preview_action_1"] },
	"argus_eyes" : { "item_image" : "saffron_bun.png", "model_path" : "res://assets/argus_eyes_pile.escn", "can_give" : false, "custom_actions" : [] },
	"greek_arrow" : { "item_image" : "saffron_bun.png", "model_path" : "res://assets/greek_arrow.escn", "can_give" : false, "custom_actions" : [] },
	"apple_jar_gg" : { "item_image" : "saffron_bun.png", "model_path" : "res://assets/apple_jar.escn", "can_give" : false, "custom_actions" : [] },
	"apple_jar_gs" : { "item_image" : "saffron_bun.png", "model_path" : "res://assets/apple_jar.escn", "can_give" : false, "custom_actions" : [] },
	"apple_jar_ss" : { "item_image" : "saffron_bun.png", "model_path" : "res://assets/apple_jar.escn", "can_give" : false, "custom_actions" : [] },
	"apple_gold" : { "item_image" : "saffron_bun.png", "model_path" : "res://assets/apple.escn", "can_give" : false, "custom_actions" : [] },
	"apple_silver" : { "item_image" : "saffron_bun.png", "model_path" : "res://assets/apple.escn", "can_give" : false, "custom_actions" : [] },
}

static func get_item_name(takable_id):
	match takable_id:
		TakableIds.APATA:
			return "statue_apata"
		TakableIds.URANIA:
			return "statue_urania"
		TakableIds.CLIO:
			return "statue_clio"
		TakableIds.MELPOMENE:
			return "statue_melpomene"
		TakableIds.ARES:
			return "statue_ares"
		TakableIds.HERMES:
			return "statue_hermes"
		TakableIds.ERIDA:
			return "statue_erida"
		TakableIds.ARTEMIDA:
			return "statue_artemida"
		TakableIds.APHRODITE:
			return "statue_aphrodite"
		TakableIds.HEBE:
			return "statue_hebe"
		TakableIds.HERA:
			return "hera_statue"
		TakableIds.APOLLO:
			return "statue_apollo"
		TakableIds.ATHENA:
			return "statue_athena"
		TakableIds.SPHERE_FOR_POSTAMENT:
			return "sphere_for_postament_body"
		TakableIds.ENVELOPE:
			return "envelope"
		TakableIds.BARN_LOCK_KEY:
			return "barn_lock_key"
		TakableIds.GREEK_SWORD:
			return "sword_body"
		TakableIds.LYRE_RAT:
			return "lyre_rat"
		TakableIds.LYRE_SNAKE:
			return "lyre_snake"
		TakableIds.LYRE_SPIDER:
			return "lyre_spider"
		TakableIds.ARGUS_EYES:
			return "argus_eyes"
		TakableIds.GREEK_ARROW:
			return "greek_arrow"
		TakableIds.APPLE_JAR_GG:
			return "apple_jar_gg"
		TakableIds.APPLE_JAR_GS:
			return "apple_jar_gs"
		TakableIds.APPLE_JAR_SS:
			return "apple_jar_ss"
		TakableIds.NONE:
			continue
		_:
			return null