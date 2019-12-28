extends Node

signal item_taken(nam, count)
signal item_removed(nam, count)

const MAX_QUICK_ITEMS = 3

var scene_path = "res://forest.tscn"
var slot_to_load_from = -1
var player_path = null
var companion_path = null
enum ApataTrapStages { ARMED = 0, GOING_DOWN = 1, PAUSED = 2, DISABLED = 3 }
var story_vars = {
"is_game_start" : true,
"flashlight_on" : false,
"apata_chest_rigid" : 0,
"relationship_female" : 0,
"relationship_bandit" : 0,
"hope_on_pedestal" : false,
"apata_trap_stage" : ApataTrapStages.ARMED
}
var items = {
	"saffron_bun" : { "item_image" : "saffron_bun.png", "model_path" : "res://scenes/bun.tscn" },
	"statue_apata" : { "item_image" : "statue_apata.png", "model_path" : "res://scenes/statue_4.tscn" },
	"statue_clio" : { "item_image" : "statue_clio.png", "model_path" : "res://scenes/statue_2.tscn" },
	"statue_melpomene" : { "item_image" : "statue_melpomene.png", "model_path" : "res://scenes/statue_3.tscn" },
	"statue_urania" : { "item_image" : "statue_urania.png", "model_path" : "res://scenes/statue_1.tscn" },
	"statue_hermes" : { "item_image" : "saffron_bun.png", "model_path" : "res://scenes/statue_hermes.tscn" },
	"sphere_for_postament_body" : { "item_image" : "saffron_bun.png", "model_path" : "res://scenes/sphere_for_postament_body.tscn" },
	"statue_ares" : { "item_image" : "saffron_bun.png", "model_path" : "res://scenes/statue_ares.tscn" },
	"statue_erida" : { "item_image" : "saffron_bun.png", "model_path" : "res://scenes/statue_erida.tscn" },
	"statue_artemida" : { "item_image" : "saffron_bun.png", "model_path" : "res://scenes/statue_artemida.tscn" },
	"statue_aphrodite" : { "item_image" : "saffron_bun.png", "model_path" : "res://scenes/statue_aphrodite.tscn" },
	"statue_hebe" : { "item_image" : "saffron_bun.png", "model_path" : "res://scenes/statue_hebe.tscn" },
	"hera_statue" : { "item_image" : "saffron_bun.png", "model_path" : "res://scenes/hera_statue.tscn" },
	"statue_apollo" : { "item_image" : "saffron_bun.png", "model_path" : "res://scenes/statue_apollo.tscn" },
	"statue_athena" : { "item_image" : "saffron_bun.png", "model_path" : "res://scenes/statue_athena.tscn" },
}
var inventory = [
]
var quick_items = [
	{ "nam" : "saffron_bun", "count" : 1 }
]
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
var doors = {
}
var lights = {
}
var containers = {
}
var takables = {
}
var music = {}
var current_music = null
var is_loop = {
	"loading.ogg" : true,
	"underwater.ogg" : true,
	"sinkingisland.ogg" : true
}

func _ready():
	add_music("loading.ogg")
	add_music("underwater.ogg")
	add_music("sinkingisland.ogg")

func get_player():
	return get_node(player_path) if player_path else null

func get_companion():
	return get_node(companion_path) if companion_path else null

func is_inside():
	return scene_path == "res://palladium.tscn"

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
	if slot_to_load_from > 0:
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
	if not items.has(nam):
		print("WARN: Unknown item name: " + nam)
		return
	var item_image = items[nam].item_image
	var model_path = items[nam].model_path
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

func load_params(slot):
	var player = get_node(player_path)
	var hud = player.get_hud()
	StoryNode.ReloadAllSaves(slot)
	
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

	var companion = get_node(companion_path)
	var player_basis = player.get_transform().basis
	var player_origin = player.get_transform().origin
	var companion_basis = companion.get_transform().basis
	var companion_origin = companion.get_transform().origin

	if ("player_path" in d):
		player_path = d.player_path

	if ("player_basis" in d and (typeof(d.player_basis) == TYPE_ARRAY)):
		var bx = Vector3(d.player_basis[0][0], d.player_basis[0][1], d.player_basis[0][2])
		var by = Vector3(d.player_basis[1][0], d.player_basis[1][1], d.player_basis[1][2])
		var bz = Vector3(d.player_basis[2][0], d.player_basis[2][1], d.player_basis[2][2])
		player_basis = Basis(bx, by, bz)

	if ("player_origin" in d and (typeof(d.player_origin) == TYPE_ARRAY)):
		player_origin = Vector3(d.player_origin[0], d.player_origin[1], d.player_origin[2])

	if ("companion_path" in d):
		companion_path = d.companion_path

	if ("companion_basis" in d and (typeof(d.companion_basis) == TYPE_ARRAY)):
		var bx = Vector3(d.companion_basis[0][0], d.companion_basis[0][1], d.companion_basis[0][2])
		var by = Vector3(d.companion_basis[1][0], d.companion_basis[1][1], d.companion_basis[1][2])
		var bz = Vector3(d.companion_basis[2][0], d.companion_basis[2][1], d.companion_basis[2][2])
		companion_basis = Basis(bx, by, bz)

	if ("companion_origin" in d and (typeof(d.companion_origin) == TYPE_ARRAY)):
		companion_origin = Vector3(d.companion_origin[0], d.companion_origin[1], d.companion_origin[2])

	player.set_transform(Transform(player_basis, player_origin))
	companion.set_transform(Transform(companion_basis, companion_origin))

	if ("story_vars" in d):
		story_vars = d.story_vars
	
	if ("inventory" in d):
		inventory = d.inventory
	
	if ("quick_items" in d):
		quick_items = d.quick_items
	
	if ("doors" in d):
		doors = d.doors
	
	if ("lights" in d):
		lights = d.lights
	
	if ("containers" in d):
		containers = d.containers
	
	if ("takables" in d):
		takables = d.takables
	
	get_tree().call_group("restorable_state", "restore_state")

func save_params(slot):
	var f = File.new()
	var error = f.open("user://saves/slot_%d/params.json" % slot, File.WRITE)
	assert( not error )
	
	var player = get_node(player_path)
	var companion = get_node(companion_path)
	var player_basis = player.get_transform().basis
	var player_origin = player.get_transform().origin
	var companion_basis = companion.get_transform().basis
	var companion_origin = companion.get_transform().origin

	var d = {
		"scene_path" : scene_path,
		"player_path" : player_path,
		"player_origin" : [player_origin.x, player_origin.y, player_origin.z],
		"player_basis" : [
			[player_basis.x.x, player_basis.x.y, player_basis.x.z],
			[player_basis.y.x, player_basis.y.y, player_basis.y.z],
			[player_basis.z.x, player_basis.z.y, player_basis.z.z]
		],
		"companion_path" : companion_path,
		"companion_origin" : [companion_origin.x, companion_origin.y, companion_origin.z],
		"companion_basis" : [
			[companion_basis.x.x, companion_basis.x.y, companion_basis.x.z],
			[companion_basis.y.x, companion_basis.y.y, companion_basis.y.z],
			[companion_basis.z.x, companion_basis.z.y, companion_basis.z.z]
		],
		"story_vars" : story_vars,
		"inventory" : inventory,
		"quick_items" : quick_items,
		"doors" : doors,
		"lights" : lights,
		"containers" : containers,
		"takables" : takables
	}
	f.store_line( to_json(d) )

func _on_MusicPlayer_finished():
	if current_music and is_loop[current_music]:
		# Make the loop programmatically, because loop in ogg import parameters doesn't work if the track is assigned programmatically
		$MusicPlayer.play()
