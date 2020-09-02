extends Node
class_name PLDGameState

signal shader_cache_processed()
signal player_registered(player)
signal player_surge(player, enabled)
signal player_underwater(player, enabled)
signal player_poisoned(player, enabled)
signal item_taken(item_id, count, item_path)
signal item_removed(item_id, count)
signal item_used(player_node, target, item_id)
signal health_changed(name_hint, health_current, health_max)
signal oxygen_changed(name_hint, oxygen_current, oxygen_max)

enum TrapStages {
	ARMED = 0,
	DISABLED = 1,
	ACTIVE = 2,
	PAUSED = 3
}
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

const DOORS_DEFAULT = {}
const LIGHTS_DEFAULT = {}
const CONTAINERS_DEFAULT = {}
const TAKABLES_DEFAULT = {}
const MULTISTATES_DEFAULT = {}
const MESSAGES_DEFAULT = {
	"MESSAGE_CONTROLS_MOVE" : true,
	"MESSAGE_CONTROLS_ITEMS" : true,
	"MESSAGE_CONTROLS_ITEMS_KEYS" : true,
	"MESSAGE_CONTROLS_INVENTORY" : true,
	"MESSAGE_CONTROLS_EXAMINE" : true,
	"MESSAGE_CONTROLS_FLASHLIGHT" : true,
	"MESSAGE_CONTROLS_CROUCH" : true,
	"MESSAGE_CONTROLS_DIALOGUE_1" : true,
	"MESSAGE_CONTROLS_DIALOGUE_2" : true
}

var slot_to_load_from = -1
var scene_path = DB.SCENE_PATH_DEFAULT
var player_name_hint = DB.PLAYER_NAME_HINT
var player_health_current = DB.PLAYER_HEALTH_CURRENT_DEFAULT
var player_health_max = DB.PLAYER_HEALTH_MAX_DEFAULT
var player_oxygen_current = DB.PLAYER_OXYGEN_CURRENT_DEFAULT
var player_oxygen_max = DB.PLAYER_OXYGEN_MAX_DEFAULT
var party = DB.PARTY_DEFAULT.duplicate(true)
var underwater = DB.UNDERWATER_DEFAULT.duplicate(true)
var poisoned = DB.POISONED_DEFAULT.duplicate(true)
var player_paths = {}
var usable_paths = {}
var story_vars = DB.STORY_VARS_DEFAULT.duplicate(true)
var inventory = DB.INVENTORY_DEFAULT.duplicate(true)
var quick_items = DB.QUICK_ITEMS_DEFAULT.duplicate(true)
var doors = DOORS_DEFAULT.duplicate(true)
var lights = LIGHTS_DEFAULT.duplicate(true)
var containers = CONTAINERS_DEFAULT.duplicate(true)
var takables = TAKABLES_DEFAULT.duplicate(true)
var multistates = MULTISTATES_DEFAULT.duplicate(true)
var messages = MESSAGES_DEFAULT.duplicate(true)

enum MusicId {LOADING, OUTSIDE, EXPLORE, MINOTAUR}
const MUSIC_PATH_TEMPLATE = "res://music/%s"
onready var music = {
	MusicId.LOADING : load(MUSIC_PATH_TEMPLATE % "loading.ogg"),
	MusicId.OUTSIDE : load(MUSIC_PATH_TEMPLATE % "underwater.ogg"),
	MusicId.EXPLORE : null,
	MusicId.MINOTAUR : load(MUSIC_PATH_TEMPLATE % "sinkingisland.ogg")
}

enum SoundId {LYRE_CORRECT, LYRE_WRONG, SNAKE_HISS}
const SOUND_PATH_TEMPLATE = "res://sound/environment/%s"
onready var sound = {
	SoundId.LYRE_CORRECT : load(SOUND_PATH_TEMPLATE % "Apollo_lyre_good_2.ogg"),
	SoundId.LYRE_WRONG : load(SOUND_PATH_TEMPLATE % "Apollo_bad_lyre_sound.ogg"),
	SoundId.SNAKE_HISS : load(SOUND_PATH_TEMPLATE % "Labyrinth_snake_hiss.ogg")
}

var current_music = null

func _ready():
	cleanup_paths()
	reset_variables()

func cleanup_paths():
	player_paths.clear()
	usable_paths.clear()

func reset_variables():
	scene_path = DB.SCENE_PATH_DEFAULT
	player_name_hint = DB.PLAYER_NAME_HINT
	player_health_current = DB.PLAYER_HEALTH_CURRENT_DEFAULT
	player_health_max = DB.PLAYER_HEALTH_MAX_DEFAULT
	player_oxygen_current = DB.PLAYER_OXYGEN_CURRENT_DEFAULT
	player_oxygen_max = DB.PLAYER_OXYGEN_MAX_DEFAULT
	party = DB.PARTY_DEFAULT.duplicate(true)
	underwater = DB.UNDERWATER_DEFAULT.duplicate(true)
	poisoned = DB.POISONED_DEFAULT.duplicate(true)
	story_vars = DB.STORY_VARS_DEFAULT.duplicate(true)
	inventory = DB.INVENTORY_DEFAULT.duplicate(true)
	quick_items = DB.QUICK_ITEMS_DEFAULT.duplicate(true)
	doors = DOORS_DEFAULT.duplicate(true)
	lights = LIGHTS_DEFAULT.duplicate(true)
	containers = CONTAINERS_DEFAULT.duplicate(true)
	takables = TAKABLES_DEFAULT.duplicate(true)
	multistates = MULTISTATES_DEFAULT.duplicate(true)
	messages = MESSAGES_DEFAULT.duplicate(true)

func get_hud():
	return get_node("/root/HUD/hud")

func get_viewport():
	return get_node("/root/HUD/ViewportContainer/Viewport")

func get_player():
	return get_node(player_paths[player_name_hint]) if has_character(player_name_hint) else null

func get_companion(name_hint = null):
	if not name_hint:
		var companions = get_companions()
		return companions[0] if companions.size() > 0 else null
	return get_node(player_paths[name_hint]) if has_character(name_hint) else null

func get_companions():
	var result = []
	for name_hint in party.keys():
		if party[name_hint] and name_hint != player_name_hint:
			var companion_node = get_node(player_paths[name_hint]) if has_character(name_hint) else null
			if companion_node:
				result.append(companion_node)
	return result

func has_character(name_hint):
	return name_hint and player_paths.has(name_hint) and has_node(player_paths[name_hint])

func get_character(name_hint):
	return get_node(player_paths[name_hint]) if has_character(name_hint) else null

func get_characters():
	var result = []
	for name_hint in party.keys():
		var character_node = get_node(player_paths[name_hint]) if has_character(name_hint) else null
		if character_node:
			result.append(character_node)
	return result

func get_usable_path(usable_id):
	if not usable_id or usable_id == DB.UsableIds.NONE:
		return null
	return usable_paths[usable_id]

func get_usable(usable_id):
	var usable_path = get_usable_path(usable_id)
	if not usable_path:
		return null
	return get_node(usable_path)

func get_level():
	var viewport = get_viewport()
	return viewport.get_child(0) if viewport.get_child_count() > 0 else null

func is_inside():
	var level = get_level()
	return level.is_inside() if level else true

func is_bright():
	var level = get_level()
	return level.is_bright() if level else false

func is_underwater(name_hint):
	return underwater.has(name_hint) and underwater[name_hint]

func is_poisoned(name_hint):
	return poisoned.has(name_hint) and poisoned[name_hint]

func set_surge(player, enable):
	emit_signal("player_surge", player, enable)

func set_underwater(player, enable):
	underwater[player.get_name_hint()] = enable
	emit_signal("player_underwater", player, enable)

func set_poisoned(player, enable):
	poisoned[player.get_name_hint()] = enable
	emit_signal("player_poisoned", player, enable)

func _on_cutscene_finished(player, cutscene_id):
	player.set_look_transition(true)
	player.stop_cutscene()

func get_custom_actions(item):
	var item_record = get_registered_item_data(item.item_id)
	return item_record.custom_actions.duplicate() if item_record else []

func execute_custom_action(event, item):
	var result = false
	if event.is_action_pressed("item_preview_action_1"):
		match item.item_id:
			DB.TakableIds.BUN:
				result = true
				item.remove()
				var player = game_state.get_player()
				if is_in_party(DB.FEMALE_NAME_HINT):
					conversation_manager.start_conversation(player, "BunEaten")
			DB.TakableIds.ENVELOPE:
				result = true
				item.remove()
				take(DB.TakableIds.BARN_LOCK_KEY)
				take(DB.TakableIds.ISLAND_MAP_2)
			DB.TakableIds.LYRE_SNAKE, DB.TakableIds.LYRE_SPIDER:
				play_sound(SoundId.LYRE_WRONG)
				kill_party()
			DB.TakableIds.LYRE_RAT:
				play_sound(SoundId.LYRE_CORRECT)
				if story_vars.in_lyre_area:
					emit_signal("item_used", item.item_id, null)
				conversation_manager.start_area_conversation_with_companion({
					DB.FEMALE_NAME_HINT : "076_Mouse_running" if story_vars.in_lyre_area else "075_Nothing_is_happening",
					DB.BANDIT_NAME_HINT : "087_Mouse_started_running" if story_vars.in_lyre_area else "086-1_Nothing_is_happening"
				})
	elif event.is_action_pressed("item_preview_action_2"):
		pass
	elif event.is_action_pressed("item_preview_action_3"):
		pass
	elif event.is_action_pressed("item_preview_action_4"):
		pass
	else:
		return false
	return result

func shader_cache_processed():
	emit_signal("shader_cache_processed")

func handle_conversation(player, target, initiator):
	if conversation_manager.arrange_meeting(player, target, initiator):
		return
	if not target.is_in_party():
		return
	var hud = get_hud()
	var item = hud.get_active_item()
	if item and item.item_id == DB.TakableIds.BUN:
		hud.inventory.visible = false
		item.used(player, target)
		item.remove()
		conversation_manager.start_conversation(player, "Bun", target)
	else:
		conversation_manager.start_conversation(player, "Conversation", target)

func can_be_given(item):
	return item and DB.ITEMS[item.item_id] and DB.ITEMS[item.item_id].can_give

func handle_player_highlight(initiator, target):
	if not target.is_in_party():
		return "E: " + tr("ACTION_TALK") if conversation_manager.meeting_is_not_finished(target.name_hint, initiator.name_hint) else ""
	var hud = get_hud()
	var item = hud.get_active_item()
	return "E: " + tr("ACTION_GIVE") if can_be_given(item) else "E: " + tr("ACTION_TALK")

func change_scene(scene_path):
	self.scene_path = scene_path
	get_tree().change_scene("res://addons/palladium/ui/scene_loader.tscn")

func initiate_load(slot):
	var f = File.new()
	var error = f.open("user://saves/slot_%d/state.json" % slot, File.READ)

	if (error):
		print("no state to load.")
		return

	var d = parse_json( f.get_as_text() )
	if (typeof(d) != TYPE_DICTIONARY) or (typeof(d.story_vars) != TYPE_DICTIONARY):
		return

	if ("scene_path" in d):
		reset_variables()
		slot_to_load_from = slot
		change_scene(d.scene_path)

func is_loading():
	return slot_to_load_from >= 0

func finish_load():
	if is_loading():
		load_state(slot_to_load_from)
		slot_to_load_from = -1
		return true
	return false

func change_music_to(music_id):
	if current_music != music_id:
		current_music = music_id
		$MusicPlayer.stream = music[music_id]
		$MusicPlayer.play()

func play_sound(sound_id, is_loop = false):
	var stream = sound[sound_id]
	if stream is AudioStreamOGGVorbis:
		stream.set_loop(is_loop)
	elif stream is AudioStreamSample:
		stream.set_loop_mode(AudioStreamSample.LoopMode.LOOP_FORWARD if is_loop else AudioStreamSample.LoopMode.LOOP_DISABLED)
	$SoundPlayer.stream = stream
	$SoundPlayer.play()

func stop_music():
	$MusicPlayer.stop()
	current_music = null

func is_item_registered(item_id):
	return DB.ITEMS.has(item_id)

func get_registered_item_data(item_id):
	return DB.ITEMS[item_id] if is_item_registered(item_id) else null

func has_item(item_id):
	if not item_id or item_id == DB.TakableIds.NONE:
		return false
	for quick_item in quick_items:
		if item_id == quick_item.item_id:
			return true
	for item in inventory:
		if item_id == item.item_id:
			return true
	return false

func get_quick_items_count():
	var result = 0
	for quick_item in quick_items:
		if quick_item.item_id and quick_item.item_id != DB.TakableIds.NONE:
			result = result + 1
	return result

func take(item_id, item_path = null, count = 1):
	if not is_item_registered(item_id):
		push_error("Unknown item_id: " + str(item_id))
		return
	var item_image = DB.ITEMS[item_id].item_image
	var model_path = DB.ITEMS[item_id].model_path
	var maxpos = 0
	for quick_item in quick_items:
		if not quick_item.item_id or quick_item.item_id == DB.TakableIds.NONE:
			quick_item.item_id = item_id
			quick_item.count = count
			emit_signal("item_taken", item_id, quick_item.count, item_path)
			return
		if item_id == quick_item.item_id:
			quick_item.count = quick_item.count + count
			emit_signal("item_taken", item_id, quick_item.count, item_path)
			return
		maxpos = maxpos + 1
	if maxpos < DB.MAX_QUICK_ITEMS:
		quick_items.append({ "item_id" : item_id, "count" : count })
		emit_signal("item_taken", item_id, count, item_path)
		return
	for item in inventory:
		if item_id == item.item_id:
			item.count = item.count + count
			emit_signal("item_taken", item_id, item.count, item_path)
			return
	inventory.append({ "item_id" : item_id, "count" : count })
	emit_signal("item_taken", item_id, count, item_path)
	get_hud().queue_popup_message("MESSAGE_CONTROLS_INVENTORY", ["TAB"])

func remove(item_id, count = 1):
	var idx = 0
	for item in inventory:
		if item_id == item.item_id:
			item.count = item.count - count
			if item.count <= 0:
				inventory.remove(idx)
			emit_signal("item_removed", item_id, item.count)
			return
		idx = idx + 1
	for quick_item in quick_items:
		if item_id == quick_item.item_id:
			quick_item.count = quick_item.count - count
			if quick_item.count <= 0:
				quick_item.item_id = null
			emit_signal("item_removed", item_id, quick_item.count)
			return

func item_used(player_node, target, item_id):
	emit_signal("item_used", item_id, target)

func set_quick_item(pos, item_id):
	if pos >= DB.MAX_QUICK_ITEMS:
		return
	for i in range(quick_items.size(), pos + 1):
		quick_items.append({ "item_id" : null, "count" : 0 })
	var existing_quick_item = quick_items[pos]
	for quick_item in quick_items:
		if item_id == quick_item.item_id:
			var new_item = { "item_id" : item_id, "count" : quick_item.count }
			quick_item.item_id = existing_quick_item.item_id
			quick_item.count = existing_quick_item.count
			quick_items[pos] = new_item
			return
	var idx = 0
	for item in inventory:
		if item_id == item.item_id:
			var new_item = { "item_id" : item_id, "count" : item.count }
			if existing_quick_item.item_id:
				item.item_id = existing_quick_item.item_id
				item.count = existing_quick_item.count
			else:
				inventory.remove(idx)
			quick_items[pos] = new_item
			return
		idx = idx + 1

func set_player_name_hint(name_hint):
	player_name_hint = name_hint

func kill_party():
	set_health(DB.PLAYER_NAME_HINT, 0, player_health_max)

func set_health(name_hint, health_current, health_max):
	# TODO: use name_hint to set health for different characters
	if health_current <= 0:
		get_tree().change_scene("res://addons/palladium/ui/game_over.tscn")
		return
	player_health_current = health_current if health_current < health_max else health_max
	player_health_max = health_max
	emit_signal("health_changed", name_hint, player_health_current, player_health_max)

func set_oxygen(name_hint, oxygen_current, oxygen_max):
	# TODO: use name_hint to set oxygen for different characters
	if oxygen_current < 0:
		set_health(name_hint, player_health_current - DB.SUFFOCATION_DAMAGE_RATE, player_health_max)
		return
	player_oxygen_current = oxygen_current if oxygen_current < oxygen_max else oxygen_max
	player_oxygen_max = oxygen_max
	emit_signal("oxygen_changed", name_hint, player_oxygen_current, player_oxygen_max)

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

func get_message_state(message_key):
	return messages[message_key] if messages.has(message_key) else true

func set_message_state(message_key, state):
	# You can set state only for messages that are registered from the very start of the game
	if messages.has(message_key):
		messages[message_key] = state

func is_in_party(name_hint):
	return party[name_hint] if party.has(name_hint) else false

func join_party(name_hint):
	var character = get_character(name_hint)
	character.clear_path()
	party[name_hint] = true
	character.reset_movement_and_rotation()

func leave_party(name_hint):
	var character = get_character(name_hint)
	character.clear_path()
	party[name_hint] = false
	character.reset_movement_and_rotation()

func register_player(player):
	player_paths[player.name_hint] = player.get_path()
	player.get_model().connect("cutscene_finished", self, "_on_cutscene_finished")
	player.set_look_transition()
	emit_signal("player_registered", player)

func register_usable(usable):
	var usable_id = usable.get_usable_id()
	if not usable_id or usable_id == DB.UsableIds.NONE:
		return
	usable_paths[usable_id] = usable.get_path()

func save_slot_exists(slot):
	var f = File.new()
	return f.file_exists("user://saves/slot_%d/state.json" % slot)

func load_state(slot):
	var hud = get_hud()
	story_node.reload_all_saves(slot)
	
	var f = File.new()
	var error = f.open("user://saves/slot_%d/state.json" % slot, File.READ)

	if (error):
		print("no state to load.")
		return

	var d = parse_json( f.get_as_text() )
	if (typeof(d) != TYPE_DICTIONARY) or (typeof(d.story_vars) != TYPE_DICTIONARY):
		return

	scene_path = d.scene_path if ("scene_path" in d) else DB.SCENE_PATH_DEFAULT
	
	player_name_hint = d.player_name_hint if ("player_name_hint" in d) else DB.PLAYER_NAME_HINT
	player_health_current = int(d.player_health_current) if ("player_health_current" in d) else DB.PLAYER_HEALTH_CURRENT_DEFAULT
	player_health_max = int(d.player_health_max) if ("player_health_max" in d) else DB.PLAYER_HEALTH_MAX_DEFAULT
	player_oxygen_current = int(d.player_oxygen_current) if ("player_oxygen_current" in d) else DB.PLAYER_OXYGEN_CURRENT_DEFAULT
	player_oxygen_max = int(d.player_oxygen_max) if ("player_oxygen_max" in d) else DB.PLAYER_OXYGEN_MAX_DEFAULT

	emit_signal("health_changed", DB.PLAYER_NAME_HINT, player_health_current, player_health_max)
	emit_signal("oxygen_changed", DB.PLAYER_NAME_HINT, player_oxygen_current, player_oxygen_max)

	party = d.party if ("party" in d) else DB.PARTY_DEFAULT.duplicate(true)
	# player_paths should not be loaded, it must be recreated on level startup via register_player()
	# usable_paths should not be loaded, it must be recreated on level startup via register_usable()
	
	underwater = d.underwater if ("underwater" in d) else DB.UNDERWATER_DEFAULT.duplicate(true)
	poisoned = d.poisoned if ("poisoned" in d) else DB.POISONED_DEFAULT.duplicate(true)
	
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
			
			if ("target_path" in dd and dd.target_path and has_node(dd.target_path)):
				character.set_target_node(get_node(dd.target_path))
			
			if ("is_crouching" in dd and dd.is_crouching):
				character.is_crouching = dd.is_crouching
			
			if ("relationship" in dd):
				character.relationship = dd.relationship
			
			if ("stuns_count" in dd):
				character.stuns_count = dd.stuns_count
			
			character.set_look_transition()
			set_underwater(character, is_underwater(name_hint))
			set_poisoned(character, is_poisoned(name_hint))

	story_vars = d.story_vars if ("story_vars" in d) else DB.STORY_VARS_DEFAULT.duplicate(true)
	inventory = sanitize_items(d.inventory) if ("inventory" in d) else DB.INVENTORY_DEFAULT.duplicate(true)
	quick_items = sanitize_items(d.quick_items) if ("quick_items" in d) else DB.QUICK_ITEMS_DEFAULT.duplicate(true)
	doors = d.doors if ("doors" in d) else DOORS_DEFAULT.duplicate(true)
	lights = d.lights if ("lights" in d) else LIGHTS_DEFAULT.duplicate(true)
	containers = d.containers if ("containers" in d) else CONTAINERS_DEFAULT.duplicate(true)
	takables = d.takables if ("takables" in d) else TAKABLES_DEFAULT.duplicate(true)
	multistates = d.multistates if ("multistates" in d) else MULTISTATES_DEFAULT.duplicate(true)
	messages = d.messages if ("messages" in d) else MESSAGES_DEFAULT.duplicate(true)
	
	get_tree().call_group("restorable_state", "restore_state")

# Because item_ids are saved as ints but should be enums
func sanitize_items(items):
	var result = []
	for item in items:
		result.append({ "item_id" : DB.lookup_takable_from_int(item.item_id) if item.item_id else null, "count" : int(item.count) })
	return result

func autosave_create():
	return save_state(0)

func autosave_restore():
	return initiate_load(0)

func save_state(slot):
	var f = File.new()
	var error = f.open("user://saves/slot_%d/state.json" % slot, File.WRITE)
	assert( not error )
	
	story_node.save_all(slot)
	
	var characters = {}
	for name_hint in party.keys():
		var character = get_character(name_hint)
		if character:
			var t = character.get_target_node()
			var p = is_in_party(name_hint)
			var b = t.get_transform().basis if t and not p else character.get_transform().basis
			var o = t.get_transform().origin if t and not p else character.get_transform().origin
			characters[name_hint] = {
				"basis" : [
					[b.x.x, b.x.y, b.x.z],
					[b.y.x, b.y.y, b.y.z],
					[b.z.x, b.z.y, b.z.z]
				] ,
				"origin" : [o.x, o.y, o.z],
				"target_path" : t.get_path() if t else null,
				"is_crouching" : character.is_crouching,
				"relationship" : character.relationship,
				"stuns_count" : character.stuns_count
			}
	
	# player_paths should not be saved, it must be recreated on level startup via register_player()
	# usable_paths should not be saved, it must be recreated on level startup via register_usable()
	var d = {
		"scene_path" : scene_path,
		"player_name_hint" : player_name_hint,
		"player_health_current" : player_health_current,
		"player_health_max" : player_health_max,
		"player_oxygen_current" : player_oxygen_current,
		"player_oxygen_max" : player_oxygen_max,
		"party" : party,
		"underwater" : underwater,
		"poisoned" : poisoned,
		"characters" : characters,
		"story_vars" : story_vars,
		"inventory" : inventory,
		"quick_items" : quick_items,
		"doors" : doors,
		"lights" : lights,
		"containers" : containers,
		"takables" : takables,
		"multistates" : multistates,
		"messages" : messages
	}
	f.store_line( to_json(d) )
