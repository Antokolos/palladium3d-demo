extends PLDUsable
class_name PLDHideout

var hidden_player = null

func use(player_node, camera_node):
	.use(player_node, camera_node)
	cutscene_manager.borrow_camera(player_node, get_node("camera_holder"))
	player_node.set_hidden(true)
	hidden_player = player_node

func add_highlight(player_node):
	return "E: " + tr("ACTION_HIDE")

func _input(event):
	if hidden_player and event.is_action_pressed("action"):
		hidden_player.set_hidden(false)
		cutscene_manager.restore_camera(hidden_player)
		hidden_player = null
		get_tree().set_input_as_handled()
