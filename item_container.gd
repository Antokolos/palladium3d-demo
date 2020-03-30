extends RigidBody
class_name ItemContainer

const PUSH_DIR = Vector3(0, 0, -1)
const PUSH_SPEED = 0.85
const PUSH_W = 1.15

enum ContainerIds {
	NONE = 0,
	APATA_CHEST = 10
}
export(ContainerIds) var container_id = ContainerIds.NONE
export var initially_opened = false
export var path_blocker = ""
export var path_collision_closed = "closed_door"
export var path_collision_opened = "opened_door"
export var path_animation_player = "apatha_chest/Armature004/AnimationPlayer"
export var path_door_mesh = ""
export var surface_idx_door = 0
export var anim_name = "Armature.010Action.003"

onready var animation_player = get_node(path_animation_player)
var blocker_node
var collision_closed
var collision_opened
onready var door_mesh = get_node(path_door_mesh)
var material
var outline_material
var outlined_material

var is_pushing = false

func _ready():
	blocker_node = get_node(path_blocker) if path_blocker != "" else null
	collision_closed = get_node(path_collision_closed)
	collision_opened = get_node(path_collision_opened)
#	material = door_mesh.mesh.surface_get_material(surface_idx_door)
	outline_material = load("res://outline.material")
#	outlined_material = material.duplicate()
#	outlined_material.next_pass = outline_material

func _physics_process(delta):
	if is_pushing and game_params.story_vars.apata_chest_rigid > 0 and mode != RigidBody.MODE_RIGID:
		set_mode(RigidBody.MODE_RIGID)
	elif game_params.story_vars.apata_chest_rigid <= 0 and mode != RigidBody.MODE_STATIC:
		set_mode(RigidBody.MODE_STATIC)

func _integrate_forces(state):
	if is_pushing and game_params.story_vars.apata_chest_rigid > 0 and mode == RigidBody.MODE_RIGID:
		var cur_dir = get_global_transform().basis.xform(PUSH_DIR)
		state.set_linear_velocity(cur_dir * PUSH_SPEED * (sin(PUSH_W * OS.get_ticks_msec()) + 0.8))

func do_push():
	is_pushing = true
	var cur_dir = get_global_transform().basis.xform(PUSH_DIR)
	apply_central_impulse(cur_dir)

func is_opened():
	var cs = game_params.get_container_state(get_path())
	return (cs == game_params.ContainerState.DEFAULT and initially_opened) or (cs == game_params.ContainerState.OPENED)

func open():
	if blocker_node and blocker_node.opened:
		return
	animation_player.play(anim_name)
	collision_closed.disabled = true
	collision_opened.disabled = false
	game_params.set_container_state(get_path(), true)

func close():
	animation_player.play_backwards(anim_name)
	collision_closed.disabled = false
	collision_opened.disabled = true
	game_params.set_container_state(get_path(), false)

func use(player_node):
	if animation_player.is_playing():
		return
	
	var opened = is_opened()
	if opened:
		close()
	else:
		open()

func add_highlight(player_node):
	#door_mesh.mesh.surface_set_material(surface_idx_door, null)
#	door_mesh.set_surface_material(surface_idx_door, outlined_material)
	return "E: Закрыть" if is_opened() else "E: Открыть"

func remove_highlight(player_node):
#	door_mesh.set_surface_material(surface_idx_door, null)
	#door_mesh.mesh.surface_set_material(surface_idx_door, material)
	pass

func restore_state():
	var state = game_params.get_container_state(get_path())
	if state == game_params.ContainerState.DEFAULT:
		if initially_opened:
			open()
		return
	if state == game_params.ContainerState.OPENED:
		open()
	else:
		close()
