extends RigidBody
class_name PLDUsable

signal use_usable(player_node, usable)

export(DB.UsableIds) var usable_id = DB.UsableIds.NONE

func connect_signals(target):
	connect("use_usable", target, "use_usable")

func use(player_node, camera_node):
	emit_signal("use_usable", player_node, self)

func add_highlight(player_node):
	return "E: " + tr("ACTION_USE")

func remove_highlight(player_node):
	pass
