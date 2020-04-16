extends Node
class_name GameParams

signal item_taken(nam, count)
signal item_removed(nam, count)
signal item_used(player_node, target, item_nam)
signal health_changed(name_hint, health_current, health_max)

enum ApataTrapStages { ARMED = 0, DISABLED = 1, GOING_DOWN = 2, PAUSED = 3 }
enum EridaTrapStages { ARMED = 0, DISABLED = 1, ACTIVE = 2 }
enum DoorState {
	DEFAULT = 0,
	OPENED = 1,
	CLOSED = 2
}
enum LightState {
	DEFAULT = 0,
	ON = 1,
	OFF = 2
}
enum ContainerState {
	DEFAULT = 0,
	OPENED = 1,
	CLOSED = 2
}
enum TakableState {
	DEFAULT = 0,
	PRESENT = 1,
	ABSENT = 2
}

const MAX_QUICK_ITEMS = 6
const SCENE_PATH_DEFAULT = "res://forest.tscn"
const PLAYER_HEALTH_CURRENT_DEFAULT = 100
const PLAYER_HEALTH_MAX_DEFAULT = 100
const PLAYER_NAME_HINT = "player"
const FEMALE_NAME_HINT = "female"
const BANDIT_NAME_HINT = "bandit"
const PARTY_DEFAULT = {
	PLAYER_NAME_HINT : true,
	FEMALE_NAME_HINT : false,
	BANDIT_NAME_HINT : false
}
const PLAYER_PATHS_DEFAULT = {}
const STORY_VARS_DEFAULT = {
	"is_game_start" : true,
	"flashlight_on" : false,
	"apata_chest_rigid" : 0,
	"relationship_female" : 0,
	"relationship_bandit" : 0,
	"apata_trap_stage" : ApataTrapStages.ARMED,
	"erida_trap_stage" : EridaTrapStages.ARMED
}
const ITEMS = {
	"saffron_bun" : { "item_image" : "saffron_bun.png", "model_path" : "res://assets/bun.escn", "can_give" : true, "custom_actions" : ["item_preview_action_1"] },
	"envelope" : { "item_image" : "saffron_bun.png", "model_path" : "res://assets/envelope.escn", "can_give" : false, "custom_actions" : ["item_preview_action_1"] },
	"barn_lock_key" : { "item_image" : "saffron_bun.png", "model_path" : "res://assets/barn_lock_key.escn", "can_give" : false, "custom_actions" : [] },
	"statue_apata" : { "item_image" : "statue_apata.png", "model_path" : "res://assets/statue_4.escn", "can_give" : false, "custom_actions" : [] },
	"statue_clio" : { "item_image" : "statue_clio.png", "model_path" : "res://assets/statue_2.escn", "can_give" : false, "custom_actions" : [] },
	"statue_melpomene" : { "item_image" : "statue_melpomene.png", "model_path" : "res://assets/statue_3.escn", "can_give" : false, "custom_actions" : [] },
	"statue_urania" : { "item_image" : "statue_urania.png", "model_path" : "res://assets/statue_1.escn", "can_give" : false, "custom_actions" : [] },
	"statue_hermes" : { "item_image" : "saffron_bun.png", "model_path" : "res://assets/statue_hermes.escn", "can_give" : false, "custom_actions" : [] },
	"sphere_for_postament_body" : { "item_image" : "saffron_bun.png", "model_path" : "res://assets/sphere_for_postament_body.escn", "can_give" : false, "custom_actions" : [] },
	"statue_ares" : { "item_image" : "saffron_bun.png", "model_path" : "res://assets/statue_ares.escn", "can_give" : false, "custom_actions" : [] },
	"statue_erida" : { "item_image" : "saffron_bun.png", "model_path" : "res://assets/statue_erida.escn", "can_give" : false, "custom_actions" : [] },
	"statue_artemida" : { "item_image" : "saffron_bun.png", "model_path" : "res://assets/statue_artemida.escn", "can_give" : false, "custom_actions" : [] },
	"statue_aphrodite" : { "item_image" : "saffron_bun.png", "model_path" : "res://assets/statue_aphrodite.escn", "can_give" : false, "custom_actions" : [] },
	"statue_hebe" : { "item_image" : "saffron_bun.png", "model_path" : "res://assets/statue_hebe.escn", "can_give" : false, "custom_actions" : [] },
	"hera_statue" : { "item_image" : "saffron_bun.png", "model_path" : "res://assets/hera_statue.escn", "can_give" : false, "custom_actions" : [] },
	"statue_apollo" : { "item_image" : "saffron_bun.png", "model_path" : "res://assets/statue_apollo.escn", "can_give" : false, "custom_actions" : [] },
	"statue_athena" : { "item_image" : "saffron_bun.png", "model_path" : "res://assets/statue_athena.escn", "can_give" : false, "custom_actions" : [] },
}
const INVENTORY_DEFAULT = []
const QUICK_ITEMS_DEFAULT = [
	{ "nam" : "saffron_bun", "count" : 1 }
]
const DOORS_DEFAULT = {}
const LIGHTS_DEFAULT = {}
const CONTAINERS_DEFAULT = {}
const TAKABLES_DEFAULT = {}
const MULTISTATES_DEFAULT = {}
const MUSIC_IS_LOOP = {
	"loading.ogg" : true,
	"underwater.ogg" : true,
	"sinkingisland.ogg" : true
}

var slot_to_load_from = -1
var scene_path = SCENE_PATH_DEFAULT
var player_name_hint = PLAYER_NAME_HINT
var player_health_current = PLAYER_HEALTH_CURRENT_DEFAULT
var player_health_max = PLAYER_HEALTH_MAX_DEFAULT
var party = PARTY_DEFAULT
var player_paths = PLAYER_PATHS_DEFAULT
var story_vars = STORY_VARS_DEFAULT
var inventory = INVENTORY_DEFAULT
var quick_items = QUICK_ITEMS_DEFAULT
var doors = DOORS_DEFAULT
var lights = LIGHTS_DEFAULT
var containers = CONTAINERS_DEFAULT
var takables = TAKABLES_DEFAULT
var multistates = MULTISTATES_DEFAULT

var music = {}
var current_music = null

func _ready():
	add_music("loading.ogg")
	add_music("underwater.ogg")
	add_music("sinkingisland.ogg")

func get_hud():
	return get_node("/root/HUD/hud")

func get_viewport():
	return get_node("/root/HUD/ViewportContainer/Viewport")

func get_player():
	return get_node(player_paths[player_name_hint]) if player_paths.has(player_name_hint) else null

func get_companion(name_hint = null):
	if not name_hint:
		var companions = get_companions()
		return companions[0] if companions.size() > 0 else null
	return get_node(player_paths[name_hint]) if player_paths.has(name_hint) else null

func get_companions():
	var result = []
	for name_hint in party.keys():
		if party[name_hint] and name_hint != player_name_hint:
			var companion_node = get_node(player_paths[name_hint]) if name_hint and player_paths.has(name_hint) else null
			if companion_node:
				result.append(companion_node)
	return result

func get_character(name_hint):
	return get_node(player_paths[name_hint]) if name_hint and player_paths.has(name_hint) else null

func get_characters():
	var result = []
	for name_hint in party.keys():
		var character_node = get_node(player_paths[name_hint]) if name_hint and player_paths.has(name_hint) else null
		if character_node:
			result.append(character_node)
	return result

func is_inside():
	return scene_path != "res://forest.tscn"

func _on_cutscene_finished(player, cutscene_id):
	match player.name_hint:
		BANDIT_NAME_HINT:
			match cutscene_id:
				PalladiumCharacter.BANDIT_CUTSCENE_PUSHES_CHEST_START:
					return
		FEMALE_NAME_HINT:
			match cutscene_id:
				PalladiumCharacter.FEMALE_CUTSCENE_SITTING_STUMP:
					return
				PalladiumCharacter.FEMALE_TAKES_APATA:
					player.remove_item_from_hand()
					return
	player.stop_cutscene()

func get_custom_actions(item):
	var item_record = ITEMS[item.nam] if ITEMS.has(item.nam) else null
	return item_record.custom_actions.duplicate() if item_record else []

func execute_custom_action(event, item):
	if event.is_action_pressed("item_preview_action_1"):
		match item.nam:
			"saffron_bun":
				item.remove()
				var player = game_params.get_player()
				conversation_manager.start_conversation(player, "BunEaten")
			"envelope":
				item.remove()
				game_params.take("barn_lock_key")
			_:
				return false
	elif event.is_action_pressed("item_preview_action_2"):
		pass
	elif event.is_action_pressed("item_preview_action_3"):
		pass
	elif event.is_action_pressed("item_preview_action_4"):
		pass
	else:
		return false
	return true

func handle_conversation(player, target, initiator):
	if conversation_manager.arrange_meeting(player, target, initiator):
		return
	if not target.is_in_party():
		return
	var hud = get_hud()
	var item = hud.get_active_item()
	if item and item.nam == "saffron_bun":
		hud.inventory.visible = false
		item.used(player, target)
		item.remove()
		conversation_manager.start_conversation(player, "Bun", target)
	else:
		conversation_manager.start_conversation(player, "Conversation", target)

func can_be_given(item):
	return item and ITEMS[item.nam] and ITEMS[item.nam].can_give

func handle_player_highlight(initiator, target):
	if not target.is_in_party():
		return "E: " + tr("ACTION_TALK") if conversation_manager.meeting_is_not_finished(target.name_hint, initiator.name_hint) else ""
	var hud = get_hud()
	var item = hud.get_active_item()
	return "E: " + tr("ACTION_GIVE") if can_be_given(item) else "E: " + tr("ACTION_TALK")

func initiate_load(slot):
	var f = File.new()
	var error = f.open("user://saves/slot_%d/params.json" % slot, File.READ)

	if (error):
		print("no params to load.")
		return

	var d = parse_json( f.get_as_text() )
	if (typeof(d) != TYPE_DICTIONARY) or (typeof(d.story_vars) != TYPE_DICTIONARY):
		return

	if ("scene_path" in d):
		scene_path = d.scene_path
	slot_to_load_from = slot
	
	get_tree().change_scene("res://scene_loader.tscn")

func finish_load():
	if slot_to_load_from >= 0:
		load_params(slot_to_load_from)
		slot_to_load_from = -1
		return true
	return false

func abspath(relpath):
	var dir = Directory.new()
	dir.open(".")
	return dir.get_current_dir() + "/" + relpath

func add_music(music_file):
	if music.has(music_file):
		return music[music_file]
	var ogg_file = File.new()
	ogg_file.open(abspath("music/" + music_file), File.READ)
	var bytes = ogg_file.get_buffer(ogg_file.get_len())
	var stream = AudioStreamOGGVorbis.new()
	stream.data = bytes
	music[music_file] = stream
	return music[music_file]

func change_music_to(music_file_name):
	if current_music != music_file_name:
		current_music = music_file_name
		$MusicPlayer.stream = music[music_file_name]
		$MusicPlayer.play()

func stop_music():
	$MusicPlayer.stop()

func is_item_registered(nam):
	return ITEMS.has(nam)

func get_registered_item_data(nam):
	return ITEMS[nam] if ITEMS.has(nam) else null

func has_item(nam):
	if not nam:
		return false
	for quick_item in quick_items:
		if nam == quick_item.nam:
			return true
	for item in inventory:
		if nam == item.nam:
			return true
	return false

func take(nam):
	if not is_item_registered(nam):
		print("WARN: Unknown item name: " + nam)
		return
	var item_image = ITEMS[nam].item_image
	var model_path = ITEMS[nam].model_path
	var maxpos = 0
	for quick_item in quick_items:
		if not quick_item.nam:
			quick_item.nam = nam
			quick_item.count = 1
			emit_signal("item_taken", nam, quick_item.count)
			return
		if nam == quick_item.nam:
			quick_item.count = quick_item.count + 1
			emit_signal("item_taken", nam, quick_item.count)
			return
		maxpos = maxpos + 1
	if maxpos < MAX_QUICK_ITEMS:
		quick_items.append({ "nam" : nam, "count" : 1 })
		emit_signal("item_taken", nam, 1)
		return
	for item in inventory:
		if nam == item.nam:
			item.count = item.count + 1
			emit_signal("item_taken", nam, item.count)
			return
	inventory.append({ "nam" : nam, "count" : 1 })
	emit_signal("item_taken", nam, 1)

func remove(nam, count = 1):
	var idx = 0
	for item in inventory:
		if nam == item.nam:
			item.count = item.count - count
			if item.count <= 0:
				inventory.remove(idx)
			emit_signal("item_removed", nam, item.count)
			return
		idx = idx + 1
	for quick_item in quick_items:
		if nam == quick_item.nam:
			quick_item.count = quick_item.count - count
			if quick_item.count <= 0:
				quick_item.nam = null
			emit_signal("item_removed", nam, quick_item.count)
			return

func item_used(player_node, target, item_nam):
	emit_signal("item_used", player_node, target, item_nam)

func set_quick_item(pos, nam):
	if pos >= MAX_QUICK_ITEMS:
		return
	for i in range(quick_items.size(), pos + 1):
		quick_items.append({ "nam" : null, "count" : 0 })
	var existing_quick_item = quick_items[pos]
	for quick_item in quick_items:
		if nam == quick_item.nam:
			var new_item = { "nam" : nam, "count" : quick_item.count }
			quick_item.nam = existing_quick_item.nam
			quick_item.count = existing_quick_item.count
			quick_items[pos] = new_item
			return
	var idx = 0
	for item in inventory:
		if nam == item.nam:
			var new_item = { "nam" : nam, "count" : item.count }
			if existing_quick_item.nam:
				item.nam = existing_quick_item.nam
				item.count = existing_quick_item.count
			else:
				inventory.remove(idx)
			quick_items[pos] = new_item
			return
		idx = idx + 1

func set_player_name_hint(name_hint):
	player_name_hint = name_hint

func set_health(name_hint, health_current, health_max):
	# TODO: use name_hint to set health for different characters
	if health_current <= 0:
		get_tree().change_scene("res://game_over.tscn")
		return
	player_health_current = health_current
	player_health_max = health_max
	emit_signal("health_changed", name_hint, health_current, health_max)

func get_door_state(door_path):
	var id = scene_path + ":" + door_path
	if not doors.has(id):
		return DoorState.DEFAULT
	return DoorState.OPENED if doors[id] else DoorState.CLOSED

func set_door_state(door_path, opened):
	doors[scene_path + ":" + door_path] = opened

func get_light_state(light_path):
	var id = scene_path + ":" + light_path
	if not lights.has(id):
		return LightState.DEFAULT
	return LightState.ON if lights[id] else LightState.OFF

func set_light_state(light_path, active):
	lights[scene_path + ":" + light_path] = active

func get_container_state(container_path):
	var id = scene_path + ":" + container_path
	if not containers.has(id):
		return ContainerState.DEFAULT
	return ContainerState.OPENED if containers[id] else ContainerState.CLOSED

func set_container_state(container_path, opened):
	containers[scene_path + ":" + container_path] = opened

func get_takable_state(takable_path):
	var id = scene_path + ":" + takable_path
	if not takables.has(id):
		return TakableState.DEFAULT
	return TakableState.ABSENT if takables[id] else TakableState.PRESENT

func set_takable_state(takable_path, absent):
	takables[scene_path + ":" + takable_path] = absent

func get_multistate_state(multistate_path):
	var id = scene_path + ":" + multistate_path
	return multistates[id] if multistates.has(id) else 0

func set_multistate_state(multistate_path, state):
	multistates[scene_path + ":" + multistate_path] = state

func is_in_party(name_hint):
	return party[name_hint] if party.has(name_hint) else false

func join_party(name_hint):
	party[name_hint] = true

func leave_party(name_hint):
	party[name_hint] = false

func register_player(player):
	player_paths[player.name_hint] = player.get_path()
	connect("item_taken", player, "_on_item_taken")
	connect("item_removed", player, "_on_item_removed")
	player.get_model().connect("cutscene_finished", self, "_on_cutscene_finished")
	play_initial_cutscene(player)

func play_initial_cutscene(player):
	if player.name_hint == FEMALE_NAME_HINT:
		if conversation_manager.meeting_is_finished(FEMALE_NAME_HINT, PLAYER_NAME_HINT):
			player.stop_cutscene()
		else:
			player.play_cutscene(PalladiumCharacter.FEMALE_CUTSCENE_SITTING_STUMP)

func save_slot_exists(slot):
	var f = File.new()
	return f.file_exists("user://saves/slot_%d/params.json" % slot)

func load_params(slot):
	var hud = get_hud()
	StoryNode.ReloadAllSaves(slot)
	
	var f = File.new()
	var error = f.open("user://saves/slot_%d/params.json" % slot, File.READ)

	if (error):
		print("no params to load.")
		return

	var d = parse_json( f.get_as_text() )
	if (typeof(d) != TYPE_DICTIONARY) or (typeof(d.story_vars) != TYPE_DICTIONARY):
		return

	scene_path = d.scene_path if ("scene_path" in d) else SCENE_PATH_DEFAULT
	
	player_name_hint = d.player_name_hint if ("player_name_hint" in d) else PLAYER_NAME_HINT
	player_health_current = int(d.player_health_current) if ("player_health_current" in d) else PLAYER_HEALTH_CURRENT_DEFAULT
	player_health_max = int(d.player_health_max) if ("player_health_max" in d) else PLAYER_HEALTH_MAX_DEFAULT

	emit_signal("health_changed", PalladiumPlayer.PLAYER_NAME_HINT, player_health_current, player_health_max)

	party = d.party if ("party" in d) else PARTY_DEFAULT
	player_paths = d.player_paths if ("player_paths" in d) else PLAYER_PATHS_DEFAULT
	
	if ("characters" in d and (typeof(d.characters) == TYPE_DICTIONARY)):
		for name_hint in d.characters.keys():
			var dd = d.characters[name_hint]
			var character = get_character(name_hint)
			var character_coords = {
				"basis" : character.get_transform().basis,
				"origin" : character.get_transform().origin
			}
			if ("basis" in dd and (typeof(dd.basis) == TYPE_ARRAY)):
				var bx = Vector3(dd.basis[0][0], dd.basis[0][1], dd.basis[0][2])
				var by = Vector3(dd.basis[1][0], dd.basis[1][1], dd.basis[1][2])
				var bz = Vector3(dd.basis[2][0], dd.basis[2][1], dd.basis[2][2])
				character_coords.basis = Basis(bx, by, bz)
			
			if ("origin" in dd and (typeof(dd.origin) == TYPE_ARRAY)):
				character_coords.origin = Vector3(dd.origin[0], dd.origin[1], dd.origin[2])
			
			character.set_transform(Transform(character_coords.basis, character_coords.origin))
			play_initial_cutscene(character)

	story_vars = d.story_vars if ("story_vars" in d) else STORY_VARS_DEFAULT
	inventory = d.inventory if ("inventory" in d) else INVENTORY_DEFAULT
	quick_items = d.quick_items if ("quick_items" in d) else QUICK_ITEMS_DEFAULT
	doors = d.doors if ("doors" in d) else DOORS_DEFAULT
	lights = d.lights if ("lights" in d) else LIGHTS_DEFAULT
	containers = d.containers if ("containers" in d) else CONTAINERS_DEFAULT
	takables = d.takables if ("takables" in d) else TAKABLES_DEFAULT
	multistates = d.multistates if ("multistates" in d) else MULTISTATES_DEFAULT
	
	get_tree().call_group("restorable_state", "restore_state")

func autosave_create():
	return save_params(0)

func autosave_restore():
	return initiate_load(0)

func save_params(slot):
	var f = File.new()
	var error = f.open("user://saves/slot_%d/params.json" % slot, File.WRITE)
	assert( not error )
	
	StoryNode.SaveAll(slot)
	
	var characters = {}
	for name_hint in party.keys():
		var character = get_character(name_hint)
		if character:
			var t = character.get_preferred_target()
			var p = is_in_party(name_hint)
			var b = t.get_transform().basis if t and not p else character.get_transform().basis
			var o = t.get_transform().origin if t and not p else character.get_transform().origin
			characters[name_hint] = {
				"basis" : [
					[b.x.x, b.x.y, b.x.z],
					[b.y.x, b.y.y, b.y.z],
					[b.z.x, b.z.y, b.z.z]
				] ,
				"origin" : [o.x, o.y, o.z]
			}
	
	var d = {
		"scene_path" : scene_path,
		"player_name_hint" : player_name_hint,
		"player_health_current" : player_health_current,
		"player_health_max" : player_health_max,
		"party" : party,
		"player_paths" : player_paths,
		"characters" : characters,
		"story_vars" : story_vars,
		"inventory" : inventory,
		"quick_items" : quick_items,
		"doors" : doors,
		"lights" : lights,
		"containers" : containers,
		"takables" : takables,
		"multistates" : multistates
	}
	f.store_line( to_json(d) )

func _on_MusicPlayer_finished():
	if current_music and MUSIC_IS_LOOP[current_music]:
		# Make the loop programmatically, because loop in ogg import parameters doesn't work if the track is assigned programmatically
		$MusicPlayer.play()
