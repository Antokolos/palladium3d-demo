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

enum ActivatableState {
	DEFAULT = 0,
	ACTIVATED = 1,
	DEACTIVATED = 2,
	PAUSED = 3,
	ACTIVATED_FOREVER = 4,
	DEACTIVATED_FOREVER = 5,
	PAUSED_FOREVER = 6
}

const COLOR_WHITE = Color(1, 1, 1, 1)
const COLOR_BLACK = Color(0, 0, 0, 0)
const DOORS_DEFAULT = {}
const LIGHTS_DEFAULT = {}
const CONTAINERS_DEFAULT = {}
const TAKABLES_DEFAULT = {}
const ACTIVATABLES_DEFAULT = {}
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

var characters_transition_data = {}
var saving_disabled = false
var slot_to_load_from = -1
var scene_path = DB.SCENE_PATH_DEFAULT
var is_transition = false
var player_name_hint = ""
var player_health_current = DB.PLAYER_HEALTH_CURRENT_DEFAULT
var player_health_max = DB.PLAYER_HEALTH_MAX_DEFAULT
var player_oxygen_current = DB.PLAYER_OXYGEN_CURRENT_DEFAULT
var player_oxygen_max = DB.PLAYER_OXYGEN_MAX_DEFAULT
var player_paths = {}
var usable_paths = {}
var activatable_paths = {}
var story_vars = DB.STORY_VARS_DEFAULT.duplicate(true)
var inventory = DB.INVENTORY_DEFAULT.duplicate(true)
var quick_items = DB.QUICK_ITEMS_DEFAULT.duplicate(true)
var doors = DOORS_DEFAULT.duplicate(true)
var lights = LIGHTS_DEFAULT.duplicate(true)
var containers = CONTAINERS_DEFAULT.duplicate(true)
var takables = TAKABLES_DEFAULT.duplicate(true)
var activatables = ACTIVATABLES_DEFAULT.duplicate(true)
var multistates = MULTISTATES_DEFAULT.duplicate(true)
var messages = MESSAGES_DEFAULT.duplicate(true)

static func process_activatables(source):
	var result = {}
	for sk in source.keys():
		result[sk] = lookup_activatable_state_from_int(source[sk])
	return result

static func lookup_activatable_state_from_int(state : int):
	for activatable_state in ActivatableState:
		if state == ActivatableState[activatable_state]:
			return ActivatableState[activatable_state]
	return ActivatableState.DEFAULT

func _ready():
	cleanup_paths()
	reset_variables()

func cleanup_paths():
	player_paths.clear()
	usable_paths.clear()
	activatable_paths.clear()

func reset_variables():
	scene_path = DB.SCENE_PATH_DEFAULT
	player_name_hint = ""
	player_health_current = DB.PLAYER_HEALTH_CURRENT_DEFAULT
	player_health_max = DB.PLAYER_HEALTH_MAX_DEFAULT
	player_oxygen_current = DB.PLAYER_OXYGEN_CURRENT_DEFAULT
	player_oxygen_max = DB.PLAYER_OXYGEN_MAX_DEFAULT
	story_vars = DB.STORY_VARS_DEFAULT.duplicate(true)
	inventory = DB.INVENTORY_DEFAULT.duplicate(true)
	quick_items = DB.QUICK_ITEMS_DEFAULT.duplicate(true)
	doors = DOORS_DEFAULT.duplicate(true)
	lights = LIGHTS_DEFAULT.duplicate(true)
	containers = CONTAINERS_DEFAULT.duplicate(true)
	takables = TAKABLES_DEFAULT.duplicate(true)
	activatables = ACTIVATABLES_DEFAULT.duplicate(true)
	multistates = MULTISTATES_DEFAULT.duplicate(true)
	messages = MESSAGES_DEFAULT.duplicate(true)

func get_game_window_parent():
	return get_node("/root/HUD") if has_node("/root/HUD") else null

func play_video_cutscene(video_file_name):
	var gwp = get_game_window_parent()
	if gwp and gwp.has_node("video_cutscene"):
		gwp.get_node("video_cutscene").play(video_file_name)

func get_hud():
	var gwp = get_game_window_parent()
	return gwp.get_node("hud") if gwp and gwp.has_node("hud") else null

func get_active_item():
	var hud = game_state.get_hud()
	return hud.get_active_item() if hud else null

func get_viewport():
	return get_node("/root/HUD/ViewportContainer/Viewport")

func get_player():
	return get_node(player_paths[player_name_hint]) if has_character(player_name_hint) else null

func get_companion(name_hint = null):
	if not name_hint:
		var companions = get_companions()
		return companions[0] if companions.size() > 0 else null
	return get_node(player_paths[name_hint]) if has_character(name_hint) else null

func get_name_hints():
	var name_hints = []
	for name_hint in player_paths.keys():
		name_hints.append(name_hint)
	return name_hints

func get_companions():
	var result = []
	for character in get_characters():
		var name_hint = character.get_name_hint()
		if character.is_in_party() and name_hint != player_name_hint:
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
	for name_hint in get_name_hints():
		var character_node = get_node(player_paths[name_hint]) if has_character(name_hint) else null
		if character_node:
			result.append(character_node)
	return result

func get_usable_path(usable_id):
	if not usable_id \
		or usable_id == DB.UsableIds.NONE \
		or not usable_paths.has(usable_id):
		return null
	return usable_paths[usable_id]

func get_usable(usable_id):
	var usable_path = get_usable_path(usable_id)
	if not usable_path or not has_node(usable_path):
		return null
	return get_node(usable_path)

func get_activatable_path(activatable_id):
	if not activatable_id \
		or activatable_id == DB.ActivatableIds.NONE \
		or not activatable_paths.has(activatable_id):
		return null
	return activatable_paths[activatable_id]

func get_activatable(activatable_id):
	var activatable_path = get_activatable_path(activatable_id)
	if not activatable_path or not has_node(activatable_path):
		return null
	return get_node(activatable_path)

func get_level():
	var viewport = get_viewport()
	return viewport.get_child(0) if viewport.get_child_count() > 0 else null

func get_door(door_full_path):
	var level = get_level()
	if not level or not level.has_node("doors"):
		return null
	var doors = level.get_node("doors")
	return doors.get_node(door_full_path) if doors.has_node(door_full_path) else null

func is_inside():
	var level = get_level()
	return level.is_inside() if level else true

func is_bright():
	var level = get_level()
	return level.is_bright() if level else false

func set_surge(player, enable):
	emit_signal("player_surge", player, enable)

func set_underwater(player, enable):
	emit_signal("player_underwater", player, enable)

func set_poisoned(player, enable):
	emit_signal("player_poisoned", player, enable)

func _on_cutscene_finished(player, player_model, cutscene_id, was_active):
	player.set_look_transition(true)

func get_custom_actions(item):
	var item_record = get_registered_item_data(item.item_id)
	return item_record.custom_actions.duplicate() if item_record else []

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

func change_scene(scene_path, is_transition = false, fade_out = false):
	characters_transition_data = get_characters_data() if is_transition else {}
	self.scene_path = scene_path
	self.is_transition = is_transition
	var gwp = get_game_window_parent() if fade_out else null
	if gwp:
		change_modulation(gwp, COLOR_WHITE, COLOR_BLACK)
	else:
		get_tree().change_scene("res://addons/palladium/ui/scene_loader.tscn")

func change_modulation(node, color_start, color_end):
	var tween = $ModulationTween
	tween.interpolate_property(
		node,
		"modulate",
		color_start,
		color_end,
		1.5,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN_OUT
	)
	tween.start()

func _on_ModulationTween_tween_completed(object, key):
	var gwp = get_game_window_parent()
	if not gwp:
		return
	if object.get_instance_id() == gwp.get_instance_id() \
		and key == ":modulate" \
		and object.get("modulate") == COLOR_BLACK:
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

func is_transition():
	return is_transition

func finish_load():
	if is_loading():
		load_state(slot_to_load_from)
		slot_to_load_from = -1
		return true
	return false

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

func take(item_id, count = 1, item_path = null):
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
	set_health(CHARS.PLAYER_NAME_HINT, 0, player_health_max)

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
	if not takable_path:
		return null
	var id = scene_path + ":" + takable_path
	if not takables.has(id):
		return TakableState.DEFAULT
	return TakableState.ABSENT if takables[id] else TakableState.PRESENT

func set_takable_state(takable_path, absent):
	takables[scene_path + ":" + takable_path] = absent

func get_activatable_state_by_id(activatable_id):
	var path = get_activatable_path(activatable_id)
	return get_activatable_state(path)

func get_activatable_state(activatable_path):
	if not activatable_path:
		return null
	var id = scene_path + ":" + activatable_path
	if not activatables.has(id):
		return ActivatableState.DEFAULT
	return activatables[id]

func set_activatable_state(activatable_path, state):
	activatables[scene_path + ":" + activatable_path] = state

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

func is_saving_disabled():
	return saving_disabled

func set_saving_disabled(saving_disabled):
	self.saving_disabled = saving_disabled

func is_in_party(name_hint):
	var character = get_character(name_hint)
	return character and character.is_in_party()

func join_party(name_hint):
	var character = get_character(name_hint)
	character.join_party()

func leave_party(name_hint):
	var character = get_character(name_hint)
	character.leave_party()

func register_player(player):
	var name_hint = player.get_name_hint()
	player_paths[name_hint] = player.get_path()
	player.get_model().connect("cutscene_finished", self, "_on_cutscene_finished")
	player.set_look_transition()
	if characters_transition_data.has(name_hint):
		set_character_data(characters_transition_data[name_hint], player)
	emit_signal("player_registered", player)

func register_usable(usable):
	var usable_id = usable.get_usable_id()
	if not usable_id or usable_id == DB.UsableIds.NONE:
		return
	usable_paths[usable_id] = usable.get_path()

func register_activatable(activatable):
	var activatable_id = activatable.get_activatable_id()
	if not activatable_id or activatable_id == DB.ActivatableIds.NONE:
		return
	activatable_paths[activatable_id] = activatable.get_path()

func save_slot_exists(slot):
	var f = File.new()
	return f.file_exists("user://saves/slot_%d/state.json" % slot)

func set_characters_data(characters_data):
	var movement_datas = []
	for name_hint in characters_data.keys():
		var character = get_character(name_hint)
		if not character:
			continue
		var dd = characters_data[name_hint]
		movement_datas.append({
			"character" : character,
			"movement_data" : set_character_data(dd, character)
		})
		if name_hint == player_name_hint:
			character.become_player()
	return movement_datas

func set_character_data(dd, character):
	var movement_data = null
	var character_coords = {
		"basis" : character.get_global_transform().basis,
		"origin" : character.get_global_transform().origin
	}
	
	if dd["positions"].has(scene_path):
		var ddd = dd["positions"][scene_path]
		if ("basis" in ddd and (typeof(ddd.basis) == TYPE_ARRAY)):
			var bx = Vector3(ddd.basis[0][0], ddd.basis[0][1], ddd.basis[0][2])
			var by = Vector3(ddd.basis[1][0], ddd.basis[1][1], ddd.basis[1][2])
			var bz = Vector3(ddd.basis[2][0], ddd.basis[2][1], ddd.basis[2][2])
			character_coords.basis = Basis(bx, by, bz)
		
		if ("origin" in ddd and (typeof(ddd.origin) == TYPE_ARRAY)):
			character_coords.origin = Vector3(ddd.origin[0], ddd.origin[1], ddd.origin[2])
		
		if ("target_path" in ddd and ddd.target_path and has_node(ddd.target_path)):
			var target_node = get_node(ddd.target_path)
			character.set_target_node(target_node)
			movement_data = (
				PLDMovementData.new() \
				.clear_dir() \
				.with_rest_state(true) \
				.with_signal("arrived_to", [target_node])
			)
	
	character.set_global_transform(Transform(character_coords.basis, character_coords.origin))
	
	if ("activated" in dd):
		if dd.activated:
			character.activate()
		else:
			character.deactivate()
	
	if ("pathfinding_enabled" in dd):
		character.set_pathfinding_enabled(dd.pathfinding_enabled)
	
	if ("in_party" in dd):
		character.set_in_party(dd.in_party)
	
	if ("is_crouching" in dd and dd.is_crouching):
		character.is_crouching = dd.is_crouching
	
	if ("is_underwater" in dd):
		set_underwater(character, dd.is_underwater)
	
	if ("is_poisoned" in dd):
		set_poisoned(character, dd.is_poisoned)
	
	if ("relationship" in dd):
		character.relationship = int(dd.relationship)
	
	if ("morale" in dd):
		character.morale = int(dd.morale)
	
	if ("stuns_count" in dd):
		character.stuns_count = int(dd.stuns_count)
	
	if ("is_hidden" in dd):
		character.set_hidden(dd.is_hidden)
	
	if ("is_sprinting" in dd):
		character.set_sprinting(dd.is_sprinting)
	
	if ("force_physics" in dd):
		character.set_force_physics(dd.force_physics)
	
	if ("force_no_physics" in dd):
		character.set_force_no_physics(dd.force_no_physics)
	
	if ("force_visibility" in dd):
		character.set_force_visibility(dd.force_visibility)
	
	if ("is_patrolling" in dd):
		character.set_patrolling(dd.is_patrolling)
	
	if ("is_aggressive" in dd):
		character.set_aggressive(dd.is_aggressive)
	
	if ("dead" in dd) and dd.dead:
		# Should be the last or at least after character.set_hidden(),
		# because character.set_hidden() modifies the same collisions
		character.kill()
	
	character.set_look_transition()
	return movement_data

func load_state(slot):
	var hud = get_hud()
	var movement_datas = []
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
	
	player_name_hint = d.player_name_hint if ("player_name_hint" in d) else CHARS.PLAYER_NAME_HINT
	player_health_current = int(d.player_health_current) if ("player_health_current" in d) else DB.PLAYER_HEALTH_CURRENT_DEFAULT
	player_health_max = int(d.player_health_max) if ("player_health_max" in d) else DB.PLAYER_HEALTH_MAX_DEFAULT
	player_oxygen_current = int(d.player_oxygen_current) if ("player_oxygen_current" in d) else DB.PLAYER_OXYGEN_CURRENT_DEFAULT
	player_oxygen_max = int(d.player_oxygen_max) if ("player_oxygen_max" in d) else DB.PLAYER_OXYGEN_MAX_DEFAULT

	emit_signal("health_changed", CHARS.PLAYER_NAME_HINT, player_health_current, player_health_max)
	emit_signal("oxygen_changed", CHARS.PLAYER_NAME_HINT, player_oxygen_current, player_oxygen_max)

	# player_paths should not be loaded, it must be recreated on level startup via register_player()
	# usable_paths should not be loaded, it must be recreated on level startup via register_usable()
	# activatable_paths should not be loaded, it must be recreated on level startup via register_activatable()
	
	if ("characters" in d and (typeof(d.characters) == TYPE_DICTIONARY)):
		movement_datas = set_characters_data(d.characters)
		characters_transition_data = d.characters

	story_vars = d.story_vars if ("story_vars" in d) else DB.STORY_VARS_DEFAULT.duplicate(true)
	inventory = sanitize_items(d.inventory) if ("inventory" in d) else DB.INVENTORY_DEFAULT.duplicate(true)
	quick_items = sanitize_items(d.quick_items) if ("quick_items" in d) else DB.QUICK_ITEMS_DEFAULT.duplicate(true)
	doors = d.doors if ("doors" in d) else DOORS_DEFAULT.duplicate(true)
	lights = d.lights if ("lights" in d) else LIGHTS_DEFAULT.duplicate(true)
	containers = d.containers if ("containers" in d) else CONTAINERS_DEFAULT.duplicate(true)
	takables = d.takables if ("takables" in d) else TAKABLES_DEFAULT.duplicate(true)
	activatables = process_activatables(d.activatables) if ("activatables" in d) else ACTIVATABLES_DEFAULT.duplicate(true)
	multistates = d.multistates if ("multistates" in d) else MULTISTATES_DEFAULT.duplicate(true)
	messages = d.messages if ("messages" in d) else MESSAGES_DEFAULT.duplicate(true)
	
	# Should restore state of all activatables before other restorable_state nodes
	get_tree().call_group("activatables", "restore_state")
	get_tree().call_group("restorable_state", "restore_state")
	for md in movement_datas:
		if md.character and md.movement_data:
			md.character.update_state(md.movement_data)

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

func get_characters_data():
	var characters = {}
	for character in get_characters():
		var name_hint = character.get_name_hint()
		characters[name_hint] = get_character_data(character)
	for name_hint in characters_transition_data.keys():
		if characters.has(name_hint):
			for pk in characters[name_hint]["positions"].keys():
				if pk != scene_path:
					characters[name_hint]["positions"][pk] = characters_transition_data[name_hint]["positions"][pk]
		else:
			characters[name_hint] = characters_transition_data[name_hint]
	return characters

func get_character_data(character):
	var p = character.is_in_party()
	
	var result = {
		"activated" : character.is_activated(),
		"dead" : character.is_dead(),
		"pathfinding_enabled" : character.is_pathfinding_enabled(),
		"in_party" : p,
		"is_crouching" : character.is_crouching(),
		"is_underwater" : character.is_underwater(),
		"is_poisoned" : character.is_poisoned(),
		"relationship" : character.get_relationship(),
		"morale" : character.get_morale(),
		"stuns_count" : character.get_stuns_count(),
		"is_hidden" : character.is_hidden(),
		"is_sprinting" : character.is_sprinting(),
		"force_physics" : character.is_force_physics(),
		"force_no_physics" : character.is_force_no_physics(),
		"force_visibility" : character.is_force_visibility(),
		"is_patrolling" : character.is_patrolling(),
		"is_aggressive" : character.is_aggressive(),
		"positions" : { scene_path : {}}
	}
	
	var t = character.get_target_node()
	var b = t.get_global_transform().basis if t and not p else character.get_global_transform().basis
	var o = t.get_global_transform().origin if t and not p else character.get_global_transform().origin
	result["positions"][scene_path]["basis"] = [
		[b.x.x, b.x.y, b.x.z],
		[b.y.x, b.y.y, b.y.z],
		[b.z.x, b.z.y, b.z.z]
	]
	result["positions"][scene_path]["origin"] = [o.x, o.y, o.z]
	result["positions"][scene_path]["target_path"] = t.get_path() if t else null
	return result

func save_state(slot):
	
	if saving_disabled:
		return
	
	var f = File.new()
	var error = f.open("user://saves/slot_%d/state.json" % slot, File.WRITE)
	assert( not error )
	
	story_node.save_all(slot)
	
	var characters = get_characters_data()
	
	# player_paths should not be saved, it must be recreated on level startup via register_player()
	# usable_paths should not be saved, it must be recreated on level startup via register_usable()
	# activatable_paths should not be loaded, it must be recreated on level startup via register_activatable()
	var d = {
		"scene_path" : scene_path,
		"player_name_hint" : player_name_hint,
		"player_health_current" : player_health_current,
		"player_health_max" : player_health_max,
		"player_oxygen_current" : player_oxygen_current,
		"player_oxygen_max" : player_oxygen_max,
		"characters" : characters,
		"story_vars" : story_vars,
		"inventory" : inventory,
		"quick_items" : quick_items,
		"doors" : doors,
		"lights" : lights,
		"containers" : containers,
		"takables" : takables,
		"activatables" : activatables,
		"multistates" : multistates,
		"messages" : messages
	}
	f.store_line( to_json(d) )
