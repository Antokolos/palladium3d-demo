extends Spatial
class_name Door

const ANIM_SPEED_SCALE = 0.725

enum DoorIds {
	NONE = 0,
	APATA_TRAP_INNER = 10,
	APATA_SAVE_INNER = 20,
	APATA_SAVE_OUTER = 30,
	ERIDA_TRAP_INNER = 40,
	DEMO_FINISH = 50
}
export(DoorIds) var door_id = DoorIds.NONE
export var initially_opened = false
export var door_collision_path = "StaticBody/CollisionShape"
export var anim_player_path = "door_4_armature001/AnimationPlayer"
export var anim_name_open = "door_4_armatureAction.001"

onready var anim_player = get_node(anim_player_path)
onready var door_collision = get_node(door_collision_path)

func _ready():
	restore_state()

func open(with_sound = true):
	anim_player.play(anim_name_open, -1, ANIM_SPEED_SCALE)
	door_collision.disabled = true
	game_params.set_door_state(get_path(), true)
	if with_sound and has_node("door_sound"):
		get_node("door_sound").play(false)

func close(with_sound = true):
	if with_sound and has_node("door_sound"):
		get_node("door_sound").play(true)
	anim_player.play(anim_name_open, -1, -ANIM_SPEED_SCALE, true)
	game_params.set_door_state(get_path(), false)
	door_collision.disabled = false

func is_opened():
	var state = game_params.get_door_state(get_path())
	return (state == game_params.DoorState.OPENED) or (state == game_params.DoorState.DEFAULT and initially_opened)

func restore_state():
	if is_opened():
		open(false)
	else:
		close(false)
