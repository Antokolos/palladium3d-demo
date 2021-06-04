tool
extends PLDDiscussable
class_name PLDHideout

signal use_hideout(player_node, hideout)

var hidden_player = null

func connect_signals(target):
	.connect_signals(target)
	connect("use_hideout", target, "use_hideout")

func use(player_node, camera_node):
	if Engine.editor_hint:
		return
	.use(player_node, camera_node)
	if is_conversation_finished_or_not_applicable(player_node) and all_party_members_can_hide():
		emit_signal("use_hideout", player_node, self)
		cutscene_manager.borrow_camera(player_node, get_node("camera_holder"), true)
		player_node.set_hidden(true, get_path())
		player_node.set_too_late_to_unhide(false)
		hidden_player = player_node

func all_party_members_can_hide():
	for character in game_state.get_characters():
		if character.is_in_party() and not character.can_hide():
			return false
	return true

func get_enemy_holder():
	return $enemy_holder

func get_hidden_player():
	return hidden_player

func unhide_player():
	if not hidden_player or hidden_player.is_too_late_to_unhide():
		return
	hidden_player.set_hidden(false)
	cutscene_manager.restore_camera(hidden_player)
	hidden_player = null

func get_usage_code(player_node):
	if is_conversation_finished_or_not_applicable(player_node):
		return "ACTION_HIDE" if all_party_members_can_hide() else ""
	return "ACTION_DISCUSS"

func _input(event):
	if Engine.editor_hint:
		return
	if not hidden_player or hidden_player.is_too_late_to_unhide():
		return
	if event.is_action_pressed("action"):
		unhide_player()
		get_tree().set_input_as_handled()
