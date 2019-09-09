extends Spatial

export var path_blocker = ""
export var path_collision_closed = "closed_door"
export var path_collision_opened = "opened_door"
export var path_animation_player = "../AnimationPlayer"
export var path_door_mesh = ""
export var surface_idx_door = 0
export var anim_name = "default"

var opened

onready var animation_player = get_node(path_animation_player)
var blocker_node
var collision_closed
var collision_opened
onready var door_mesh = get_node(path_door_mesh)
var material
var outline_material
var outlined_material

func _ready():
	opened = false
	blocker_node = get_node(path_blocker) if path_blocker != "" else null
	collision_closed = get_node(path_collision_closed)
	collision_opened = get_node(path_collision_opened)
#	material = door_mesh.mesh.surface_get_material(surface_idx_door)
	outline_material = load("res://outline.material")
#	outlined_material = material.duplicate()
#	outlined_material.next_pass = outline_material

func use(player_node):
	if animation_player.is_playing():
		return
	
	if opened:
		animation_player.play_backwards(anim_name)
		collision_closed.disabled = false
		collision_opened.disabled = true
		opened = false
		if game_params.apata_in_chest:
			get_node("../../door_3").open()
	elif not game_params.apata_in_chest:
		if blocker_node and blocker_node.opened:
			return
		animation_player.play(anim_name)
		collision_closed.disabled = true
		collision_opened.disabled = false
		opened = true

func add_highlight(player_node):
	#door_mesh.mesh.surface_set_material(surface_idx_door, null)
#	door_mesh.set_surface_material(surface_idx_door, outlined_material)
	return "" if game_params.apata_in_chest else ("E: Закрыть ларец" if opened else "E: Открыть ларец")

func remove_highlight(player_node):
#	door_mesh.set_surface_material(surface_idx_door, null)
	#door_mesh.mesh.surface_set_material(surface_idx_door, material)
	pass
