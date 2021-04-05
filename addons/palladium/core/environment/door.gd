extends Spatial
class_name PLDDoor

signal door_state_changed(door_id, opened)

const ANIM_SPEED_SCALE = 0.725

export(DB.DoorIds) var door_id = DB.DoorIds.NONE
export var initially_opened = false
export var reverse = false
export var door_body_path = "StaticBody"
export var anim_player_path = "door_4_armature001/AnimationPlayer"
export var anim_name_open = "door_4_armatureAction.001"
export var anim_speed_scale = ANIM_SPEED_SCALE
export(NodePath) var lock_sound_player_path = null

onready var anim_player = get_node(anim_player_path)
onready var door_body = get_node(door_body_path)
onready var lock_sound_player = get_node(lock_sound_player_path) if lock_sound_player_path and has_node(lock_sound_player_path) else null

func _ready():
	anim_player.connect("animation_finished", self, "_on_animation_finished")
	if lock_sound_player:
		lock_sound_player.connect("finished", self, "_on_lock_sound_finished")

func _on_animation_finished(anim_name):
	emit_signal("door_state_changed", door_id, is_opened())

func _on_lock_sound_finished():
	do_open(true)

func enable_collisions(body, enable):
	for collision in body.get_children():
		if collision is CollisionShape:
			collision.disabled = not enable

func do_open(with_sound, immediately = false):
	var sp = PLDGameState.SPEED_SCALE_INFINITY if immediately else anim_speed_scale
	anim_player.play(anim_name_open, -1, -sp if reverse else sp, reverse)
	enable_collisions(door_body, false)
	game_state.set_door_state(get_path(), true)
	if with_sound and has_node("door_sound"):
		get_node("door_sound").play(false)

func open(with_sound = true, force = false, immediately = false):
	if not force and is_opened():
		return false
	if not lock_sound_player or not with_sound:
		do_open(with_sound, immediately)
	else:
		lock_sound_player.play()
	return true

func close(with_sound = true, force = false, immediately = false):
	if not force and not is_opened():
		return false
	if with_sound and has_node("door_sound"):
		get_node("door_sound").play(true)
	var sp = PLDGameState.SPEED_SCALE_INFINITY if immediately else anim_speed_scale
	anim_player.play(anim_name_open, -1, sp if reverse else -sp, not reverse)
	game_state.set_door_state(get_path(), false)
	enable_collisions(door_body, true)
	return true

func is_opened():
	var state = game_state.get_door_state(get_path())
	return (state == game_state.DoorState.OPENED) or (state == game_state.DoorState.DEFAULT and initially_opened)

func restore_state():
	if is_opened():
		open(false, true, true)
	else:
		close(false, true, true)
