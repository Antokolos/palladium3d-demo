tool
extends PLDDiscussable
class_name PLDHideout

signal use_hideout(player_node, usable)

var hidden_player = null

func connect_signals(target):
	.connect_signals(target)
	connect("use_hideout", target, "use_hideout")

func use(player_node, camera_node):
	if Engine.editor_hint:
		return
	.use(player_node, camera_node)
	if is_conversation_finished_or_not_applicable(player_node):
		emit_signal("use_hideout", player_node, self)
		cutscene_manager.borrow_camera(player_node, get_node("camera_holder"))
		player_node.set_hidden(true)
		hidden_player = player_node

func add_highlight(player_node):
	if Engine.editor_hint:
		return ""
	return "E: " + tr("ACTION_HIDE") if is_conversation_finished_or_not_applicable(player_node) else "E: " + tr("ACTION_DISCUSS")

func _input(event):
	if Engine.editor_hint:
		return
	if hidden_player and event.is_action_pressed("action"):
		hidden_player.set_hidden(false)
		cutscene_manager.restore_camera(hidden_player)
		hidden_player = null
		get_tree().set_input_as_handled()
