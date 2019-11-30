extends Node

signal item_removed(nam, count)

var scene_path = "res://forest.tscn"
var slot_to_load_from = -1
var player_path = null
var companion_path = null
enum ApataTrapStages { ARMED = 0, GOING_DOWN = 1, PAUSED = 2, DISABLED = 3 }
var story_vars = {
"is_game_start" : true,
"apata_chest_rigid" : 0,
"relationship_female" : 0,
"relationship_bandit" : 0,
"hope_on_pedestal" : false,
"apata_trap_stage" : ApataTrapStages.ARMED
}
var inventory = [
	{ "nam" : "saffron_bun", "item_image" : "saffron_bun.png", "model_path" : "res://scenes/bun.tscn", "count" : 1, "quick_item_pos" : 0 }
]
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

func take(nam, item_image, model_path):
	for item in inventory:
		if nam == item.nam:
			item.count = item.count + 1
			return
	# TODO: set quick_item_pos to >0 if there is enough room in quick item panel
	inventory.append({ "nam" : nam, "item_image" : item_image, "model_path" : model_path, "count" : 1, "quick_item_pos" : -1 })

func remove(nam, count = 1):
	var idx = 0
	for item in inventory:
		if nam == item.nam:
			item.count = item.count - count
			if item.count <= 0:
				inventory.remove(idx)
			emit_signal("item_removed", item.nam, item.count)
			return
		idx = idx + 1

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
		"inventory" : inventory
	}
	f.store_line( to_json(d) )

func _on_MusicPlayer_finished():
	if current_music and is_loop[current_music]:
		# Make the loop programmatically, because loop in ogg import parameters doesn't work if the track is assigned programmatically
		$MusicPlayer.play()
