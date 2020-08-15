extends RigidBody
class_name PLDUsable

signal use_usable(player_node, usable)

const USE_DISTANCE_COMMON = 2

export(int) var use_distance = USE_DISTANCE_COMMON
export(DB.UsableIds) var usable_id = DB.UsableIds.NONE

func get_use_distance():
	return use_distance

func connect_signals(target):
	connect("use_usable", target, "use_usable")

func use(player_node, camera_node):
	emit_signal("use_usable", player_node, self)

func add_highlight(player_node):
	return "E: " + tr("ACTION_USE")

func remove_highlight(player_node):
	pass
