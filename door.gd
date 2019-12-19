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

func _ready():
	restore_state()

func open():
	get_node("door_4_armature001/AnimationPlayer").play("door_4_armatureAction.001")
	get_node("StaticBody/CollisionShape").disabled = true
	game_params.set_door_opened(door_id, true)

func close():
	get_node("door_4_armature001/AnimationPlayer").play_backwards("door_4_armatureAction.001")
	get_node("StaticBody/CollisionShape").disabled = false
	game_params.set_door_opened(door_id, false)

func restore_state():
	if game_params.is_door_opened(door_id):
		open()
	else:
		close()
