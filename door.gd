extends Spatial
class_name Door

enum DoorIds {
	NONE = 0,
	APATA_TRAP_INNER = 10,
	APATA_SAVE_INNER = 20,
	APATA_SAVE_OUTER = 30,
	ERIDA_TRAP_INNER = 40
}
export(DoorIds) var door_id = DoorIds.NONE
export var initially_opened = false

func _ready():
	restore_state()

func open():
	get_node("door_4_armature001/AnimationPlayer").play("door_4_armatureAction.001")
	get_node("StaticBody/CollisionShape").disabled = true
	game_params.set_door_state(get_path(), true)

func close():
	get_node("door_4_armature001/AnimationPlayer").play_backwards("door_4_armatureAction.001")
	get_node("StaticBody/CollisionShape").disabled = false
	game_params.set_door_state(get_path(), false)

func restore_state():
	var state = game_params.get_door_state(get_path())
	if state == game_params.DoorState.DEFAULT:
		if initially_opened:
			open()
		return
	if state == game_params.DoorState.OPENED:
		open()
	else:
		close()
