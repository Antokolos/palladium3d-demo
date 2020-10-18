extends Node
class_name PLDCutsceneManager

signal camera_borrowed(player_node, cutscene_node, conversation_name, target)
signal camera_restored(player_node, cutscene_node, conversation_name, target)

var cutscene_node = null
var conversation_name = null
var target = null
var is_cutscene = false

func _ready():
	conversation_manager.connect("conversation_finished", self, "_on_conversation_finished")

func _on_conversation_finished(player, conversation_name, target, initiator):
	if not self.target and target:
		return
	if self.target and not target:
		return
	if self.conversation_name == conversation_name:
		if (not self.target and not target) or self.target.name_hint == target.name_hint:
			stop_cutscene(player)

func start_cutscene(player, cutscene_node, conversation_name = null, target = null):
	self.conversation_name = conversation_name
	self.target = target
	borrow_camera(player, cutscene_node)

func stop_cutscene(player):
	var conversation_name_prev = self.conversation_name
	var target_prev = self.target
	self.conversation_name = null
	self.target = null
	restore_camera(player, conversation_name_prev, target_prev)

func borrow_camera(player, cutscene_node):
	is_cutscene = true
	game_state.get_hud().show_game_ui(false)
	var player_camera_holder = player.get_cam_holder()
	if player_camera_holder.get_child_count() == 0:
		# Do nothing if player has no camera. It looks like we are in cutscene already.
		return
	var camera = player_camera_holder.get_child(0)
	camera.enable_use(false)
	self.cutscene_node = cutscene_node
	if not cutscene_node:
		return
	player.reset_rotation()
	player.set_simple_mode(false)
	player_camera_holder.remove_child(camera)
	cutscene_node.add_child(camera)
	emit_signal("camera_borrowed", player, cutscene_node, conversation_name, target)

func restore_camera(player, conversation_name_prev = null, target_prev = null):
	var player_camera_holder = player.get_cam_holder()
	var cutscene_cam = get_cam()
	if cutscene_cam:
		player.reset_movement_and_rotation()
		player.set_simple_mode(true)
		cutscene_node.remove_child(cutscene_cam)
		player_camera_holder.add_child(cutscene_cam)
		cutscene_cam.enable_use(true)
		emit_signal("camera_restored", player, cutscene_node, conversation_name_prev, target_prev)
	elif player_camera_holder and player_camera_holder.get_child_count() > 0:
		var camera = player_camera_holder.get_child(0)
		camera.enable_use(true)
	cutscene_node = null
	game_state.get_hud().show_game_ui(true)
	is_cutscene = false

func get_cam():
	return cutscene_node.get_child(0) if cutscene_node and cutscene_node.get_child_count() > 0 else null

func is_cutscene():
	return is_cutscene