extends RigidBody
class_name PLDUsable

signal use_usable(player_node, usable)

const USE_DISTANCE_COMMON = 2.6

export(float) var use_distance = USE_DISTANCE_COMMON
export(DB.UsableIds) var usable_id = DB.UsableIds.NONE

func _ready():
	if Engine.editor_hint:
		return
	game_state.register_usable(self)

func get_usable_id():
	return usable_id

func get_use_distance():
	return use_distance

func connect_signals(target):
	connect("use_usable", target, "use_usable")

func get_usage_code(player_node):
	return "ACTION_USE"

func can_be_used_by(player_node):
	var uc = get_usage_code(player_node)
	return uc and not uc.empty()

func use(player_node, camera_node):
	if not can_be_used_by(player_node):
		return
	emit_signal("use_usable", player_node, self)

func add_highlight(player_node):
	var uc = get_usage_code(player_node)
	if not uc or uc.empty():
		return ""
	return common_utils.get_action_input_control() + tr(uc)

func remove_highlight(player_node):
	pass
