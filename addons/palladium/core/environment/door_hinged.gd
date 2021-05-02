extends PLDDoor
class_name PLDDoorHinged

export(NodePath) var door_body_opened_path = NodePath("StaticBodyOpened")

var door_body_opened = null

func get_door_body_opened():
	if not door_body_opened:
		door_body_opened = get_node(door_body_opened_path)
	return door_body_opened

func open(is_restoring = false):
	if not .open(is_restoring):
		return false
	enable_collisions(get_door_body_opened(), true)
	return true

func close(is_restoring = false):
	if not .close(is_restoring):
		return false
	enable_collisions(get_door_body_opened(), false)
	return true
