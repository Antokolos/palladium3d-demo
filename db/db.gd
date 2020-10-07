tool
extends Node

### COMMON PART ###
const HEALING_RATE = 1
const MAX_QUICK_ITEMS = 6
const SCENE_PATH_DEFAULT = ""
const PLAYER_HEALTH_CURRENT_DEFAULT = 100
const PLAYER_HEALTH_MAX_DEFAULT = 100
const SUFFOCATION_DAMAGE_RATE = 10
const PLAYER_OXYGEN_CURRENT_DEFAULT = 100
const PLAYER_OXYGEN_MAX_DEFAULT = 100

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

static func is_weapon_stun(takable_id):
	if not takable_id or takable_id == TakableIds.NONE:
		return false
	return WEAPONS_STUN.has(takable_id)

static func get_weapon_stun_data(takable_id):
	return WEAPONS_STUN[takable_id] if is_weapon_stun(takable_id) else null

### CODE THAT MUST BE INCLUDED IN THE GAME-SPECIFIC PART ###

#const STORY_VARS_DEFAULT = {
#	"flashlight_on" : false
#}

#enum LightIds {
#	NONE = 0
#}

#enum RiddleIds {
#	NONE = 0
#}

#enum PedestalIds {
#	NONE = 0
#}

#enum ContainerIds {
#	NONE = 0
#}

#enum DoorIds {
#	NONE = 0
#}

#enum ButtonActivatorIds {
#	NONE = 0
#}

#enum UsableIds {
#	NONE = 0
#}

#enum TakableIds {
#	NONE = 0
#}

#enum UseTargetIds {
#	NONE = 0
#}

#const INVENTORY_DEFAULT = []
#const QUICK_ITEMS_DEFAULT = []

#const ITEMS = {
#	TakableIds.NONE : { "item_nam" : "item_none", "item_image" : "none.png", "model_path" : "res://assets/none.escn", "model_use_path" : null, "can_give" : false, "custom_actions" : [] },
#}

#const WEAPONS_STUN = {
#	TakableIds.MEDUSA_HEAD : { "stun_duration" : 5 }
#}

#func execute_custom_action(event, item):
#	var result = false
#	if event.is_action_pressed("item_preview_action_1"):
#		match item.item_id:
#			_:
#				pass
#	elif event.is_action_pressed("item_preview_action_2"):
#		pass
#	elif event.is_action_pressed("item_preview_action_3"):
#		pass
#	elif event.is_action_pressed("item_preview_action_4"):
#		pass
#	else:
#		return false
#	return result

### GAME-SPECIFIC PART ###

const STORY_VARS_DEFAULT = {
	"flashlight_on" : false,
	"is_game_start" : true,
	"in_lyre_area" : false,
	"apata_chest_rigid" : 0,
	"apata_trap_stage" : PLDGameState.TrapStages.ARMED,
	"erida_trap_stage" : PLDGameState.TrapStages.ARMED
}

enum LightIds {
	NONE = 0
}

enum RiddleIds {
	NONE = 0
}

enum PedestalIds {
	NONE = 0,
	APATA = 10,
	MUSES = 20,
	HERMES_FLAT = 30,
	ERIDA_LOCK = 40,
	ERIS_FLAT = 50,
	ARES_FLAT = 60,
	DEMO_HERMES = 70,
	DEMO_ARES = 80
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
	ERIDA = 10
}

enum UsableIds {
	NONE = 0,
	BARN_LOCK = 10,
	LAST_TRAP_FLOOR = 100,
	LAST_TRAP_POSTAMENT = 110
}

enum TakableIds {
	NONE = 0,
	CELL_PHONE = 5,
	COIN = 10,
	FLASK_EMPTY = 20,
	FLASK_HEALING = 30,
	BUN = 40,
	ISLAND_MAP = 50,
	ENVELOPE = 60,
	BARN_LOCK_KEY = 70,
	ISLAND_MAP_2 = 80,
	SPHERE_FOR_POSTAMENT = 90,
	APATA = 100,
	URANIA = 110,
	CLIO = 120,
	MELPOMENE = 130,
	HERMES = 140,
	ERIDA = 150,
	ARES = 160,
	TUBE_BREATH = 170,
	ATHENA = 430,
	PALLADIUM = 440
}

enum UseTargetIds {
	NONE = 0,
	LAST_TRAP_POSTAMENT = 5
}

const INVENTORY_DEFAULT = []
const QUICK_ITEMS_DEFAULT = [
	{ "item_id" : TakableIds.CELL_PHONE, "count" : 1 },
	{ "item_id" : TakableIds.ISLAND_MAP, "count" : 1 },
	{ "item_id" : TakableIds.FLASK_EMPTY, "count" : 1 },
	{ "item_id" : TakableIds.BUN, "count" : 1 }
]

const ITEMS = {
	TakableIds.CELL_PHONE : { "item_nam" : "cell_phone", "item_image" : "cell_phone.png", "model_path" : "res://assets/cell_phone.escn", "model_use_path" : null, "can_give" : false, "custom_actions" : [] },
	TakableIds.COIN : { "item_nam" : "coin", "item_image" : "coin.png", "model_path" : "res://assets/coin.escn", "model_use_path" : null, "can_give" : false, "custom_actions" : [] },
	TakableIds.FLASK_EMPTY : { "item_nam" : "flask_empty", "item_image" : "flask.png", "model_path" : "res://assets/flask.escn", "model_use_path" : null, "can_give" : false, "custom_actions" : [] },
	TakableIds.FLASK_HEALING : { "item_nam" : "flask_healing", "item_image" : "flask.png", "model_path" : "res://assets/flask.escn", "model_use_path" : null, "can_give" : false, "custom_actions" : ["item_preview_action_1"] },
	TakableIds.BUN : { "item_nam" : "saffron_bun", "item_image" : "saffron_bun.png", "model_path" : "res://assets/bun.escn", "model_use_path" : null, "can_give" : true, "custom_actions" : ["item_preview_action_1"] },
	TakableIds.ISLAND_MAP : { "item_nam" : "island_map", "item_image" : "island_child.png", "model_path" : "res://assets/island_map.escn", "model_use_path" : null, "can_give" : false, "custom_actions" : [] },
	TakableIds.ENVELOPE : { "item_nam" : "envelope", "item_image" : "envelope.png", "model_path" : "res://assets/envelope.escn", "model_use_path" : null, "can_give" : false, "custom_actions" : ["item_preview_action_1"] },
	TakableIds.BARN_LOCK_KEY : { "item_nam" : "barn_lock_key", "item_image" : "key.png", "model_path" : "res://assets/barn_lock_key.escn", "model_use_path" : null, "can_give" : false, "custom_actions" : [] },
	TakableIds.ISLAND_MAP_2 : { "item_nam" : "island_map_2", "item_image" : "island_father.png", "model_path" : "res://assets/island_map_2.escn", "model_use_path" : null, "can_give" : false, "custom_actions" : [] },
	TakableIds.SPHERE_FOR_POSTAMENT : { "item_nam" : "sphere_for_postament_body", "item_image" : "sphere.png", "model_path" : "res://assets/sphere_for_postament.escn", "model_use_path" : null, "can_give" : false, "custom_actions" : [] },
	TakableIds.APATA : { "item_nam" : "statue_apata", "item_image" : "statue_apata.png", "model_path" : "res://assets/statue_4.escn", "model_use_path" : null, "can_give" : false, "custom_actions" : [] },
	TakableIds.URANIA : { "item_nam" : "statue_urania", "item_image" : "statue_urania.png", "model_path" : "res://assets/statue_1.escn", "model_use_path" : null, "can_give" : false, "custom_actions" : [] },
	TakableIds.CLIO : { "item_nam" : "statue_clio", "item_image" : "statue_clio.png", "model_path" : "res://assets/statue_2.escn", "model_use_path" : null, "can_give" : false, "custom_actions" : [] },
	TakableIds.MELPOMENE : { "item_nam" : "statue_melpomene", "item_image" : "statue_melpomene.png", "model_path" : "res://assets/statue_3.escn", "model_use_path" : null, "can_give" : false, "custom_actions" : [] },
	TakableIds.HERMES : { "item_nam" : "statue_hermes", "item_image" : "statue_hermes.png", "model_path" : "res://assets/statue_hermes.escn", "model_use_path" : null, "can_give" : false, "custom_actions" : [] },
	TakableIds.ERIDA : { "item_nam" : "statue_erida", "item_image" : "statue_erida.png", "model_path" : "res://assets/statue_erida.escn", "model_use_path" : null, "can_give" : false, "custom_actions" : [] },
	TakableIds.ARES : { "item_nam" : "statue_ares", "item_image" : "statue_ares.png", "model_path" : "res://assets/statue_ares.escn", "model_use_path" : null, "can_give" : false, "custom_actions" : [] },
	TakableIds.TUBE_BREATH : { "item_nam" : "tube_breath", "item_image" : "tube_breath.png", "model_path" : "res://assets/tube_breath.escn", "model_use_path" : null, "can_give" : false, "custom_actions" : [] },
	TakableIds.ATHENA : { "item_nam" : "statue_athena", "item_image" : "statue_athena.png", "model_path" : "res://assets/statue_athena.escn", "model_use_path" : null, "can_give" : false, "custom_actions" : [] },
	TakableIds.PALLADIUM: { "item_nam" : "palladium", "item_image" : "Palladium_real.png", "model_path" : "res://assets/Palladium_real.escn", "model_use_path" : null, "can_give" : false, "custom_actions" : [] },
}

const WEAPONS_STUN = {}

func execute_custom_action(event, item):
	var result = false
	if event.is_action_pressed("item_preview_action_1"):
		match item.item_id:
			DB.TakableIds.FLASK_HEALING:
				game_state.set_health(CHARS.PLAYER_NAME_HINT, game_state.player_health_current + game_state.player_health_max / 2, game_state.player_health_max)
				var last_flask = (item.get_item_count() == 1)
				item.remove()
				if last_flask:
					game_state.take(DB.TakableIds.FLASK_EMPTY)
			DB.TakableIds.BUN:
				result = true
				item.remove()
				var player = game_state.get_player()
				if game_state.is_in_party(CHARS.FEMALE_NAME_HINT):
					conversation_manager.start_conversation(player, "BunEaten")
			DB.TakableIds.ENVELOPE:
				result = true
				item.remove()
				game_state.take(DB.TakableIds.BARN_LOCK_KEY)
				game_state.take(DB.TakableIds.ISLAND_MAP_2)
	elif event.is_action_pressed("item_preview_action_2"):
		pass
	elif event.is_action_pressed("item_preview_action_3"):
		pass
	elif event.is_action_pressed("item_preview_action_4"):
		pass
	else:
		return false
	return result