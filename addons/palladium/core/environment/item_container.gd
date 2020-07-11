extends PLDUsable
class_name PLDItemContainer

enum ContainerIds {
	NONE = 0,
	APATA_CHEST = 10
}
export(ContainerIds) var container_id = ContainerIds.NONE
export var initially_opened = false
export var path_blocker = ""
export var path_collision_closed = "closed_door"
export var path_collision_opened = "opened_door"
export var path_animation_player = "apatha_chest/apatha_chest_armature_lid/AnimationPlayer"
export var path_animation_player_base = "apatha_chest/apatha_chest_armature_base/AnimationPlayer"
export var path_door_mesh = ""
export var surface_idx_door = 0
export var anim_name = "Armature.010Action.003"

onready var animation_player = get_node(path_animation_player)
onready var animation_player_base = get_node(path_animation_player_base) if has_node(path_animation_player_base) else null
var blocker_node
var collision_closed
var collision_opened
onready var door_mesh = get_node(path_door_mesh)

func _ready():
	animation_player.connect("animation_finished", self, "_on_animation_finished")
	if animation_player_base:
		animation_player_base.connect("animation_finished", self, "_on_base_animation_finished")
	blocker_node = get_node(path_blocker) if path_blocker != "" else null
	collision_closed = get_node(path_collision_closed)
	collision_opened = get_node(path_collision_opened)

func _on_animation_finished(anim_name):
	animation_player.set_speed_scale(1.0)

func _on_base_animation_finished(anim_name):
	animation_player_base.set_speed_scale(1.0)

func is_opened():
	var cs = game_params.get_container_state(get_path())
	return (cs == game_params.ContainerState.DEFAULT and initially_opened) or (cs == game_params.ContainerState.OPENED)

func open(with_sound = true, speed_scale = 1.0):
	if blocker_node and blocker_node.opened:
		return
	animation_player.set_speed_scale(speed_scale)
	animation_player.play(anim_name)
	collision_closed.disabled = true
	collision_opened.disabled = false
	game_params.set_container_state(get_path(), true)

func close(with_sound = true, speed_scale = 1.0):
	animation_player.set_speed_scale(speed_scale)
	animation_player.play_backwards(anim_name)
	collision_closed.disabled = false
	collision_opened.disabled = true
	game_params.set_container_state(get_path(), false)

func use(player_node, camera_node):
	if animation_player.is_playing():
		return
	var opened = is_opened()
	if opened:
		close()
	else:
		open()

func add_highlight(player_node):
	return "E: " + tr("ACTION_CLOSE") if is_opened() else "E: " + tr("ACTION_OPEN")

func restore_state():
	var state = game_params.get_container_state(get_path())
	if state == game_params.ContainerState.DEFAULT:
		if initially_opened:
			open(false)
		return
	if state == game_params.ContainerState.OPENED:
		open(false)
	else:
		close(false)
