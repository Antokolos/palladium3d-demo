extends PLDUsable
class_name PLDItemContainer

export(PLDDB.ContainerIds) var container_id = PLDDB.ContainerIds.NONE
export var initially_opened = false
export var path_blocker = ""
export var path_collision_closed = "closed_door"
export var path_collision_opened = "opened_door"
export var path_animation_player = "apatha_chest/apatha_chest_armature_lid/AnimationPlayer"
export var path_animation_player_base = "apatha_chest/apatha_chest_armature_base/AnimationPlayer"
export var path_sound_player_opened : NodePath = NodePath()
export var path_sound_player_closed : NodePath = NodePath()
export var surface_idx_door = 0
export var anim_name = "Armature.010Action.003"

onready var animation_player = get_node(path_animation_player)
onready var animation_player_base = get_node(path_animation_player_base) if has_node(path_animation_player_base) else null
onready var sound_player_opened = get_node(path_sound_player_opened) if not path_sound_player_opened.is_empty() and has_node(path_sound_player_opened) else null
onready var sound_player_closed = get_node(path_sound_player_closed) if not path_sound_player_closed.is_empty() and has_node(path_sound_player_closed) else null
var blocker_node
var collision_closed
var collision_opened

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
	var cs = game_state.get_container_state(get_path())
	return (cs == PLDGameState.ContainerState.DEFAULT and initially_opened) or (cs == PLDGameState.ContainerState.OPENED)

func open(is_restoring = false, speed_scale = 1.0):
	if blocker_node and blocker_node.opened:
		return
	if not is_restoring and is_opened():
		return
	animation_player.set_speed_scale(
		PLDGameState.SPEED_SCALE_INFINITY
			if is_restoring
			else speed_scale
	)
	animation_player.play(anim_name)
	collision_closed.disabled = true
	collision_opened.disabled = false
	if not is_restoring:
		game_state.set_container_state(get_path(), true)
		if sound_player_opened:
			sound_player_opened.play()

func close(is_restoring = false, speed_scale = 1.0):
	if not is_restoring and not is_opened():
		return
	animation_player.set_speed_scale(
		PLDGameState.SPEED_SCALE_INFINITY
			if is_restoring
			else speed_scale
	)
	animation_player.play_backwards(anim_name)
	collision_closed.disabled = false
	collision_opened.disabled = true
	if not is_restoring:
		game_state.set_container_state(get_path(), false)
		if sound_player_closed:
			sound_player_closed.play()

func use(player_node, camera_node):
	if animation_player.is_playing():
		return
	var opened = is_opened()
	if opened:
		close()
	else:
		open()

func get_usage_code(player_node):
	return "ACTION_CLOSE" if is_opened() else "ACTION_OPEN"

func restore_state():
	var state = game_state.get_container_state(get_path())
	if state == PLDGameState.ContainerState.DEFAULT:
		if initially_opened:
			open(true)
		return
	if state == PLDGameState.ContainerState.OPENED:
		open(true)
	else:
		close(true)
