extends Node
class_name PLDCutsceneManager

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
	self.conversation_name = null
	self.target = null
	restore_camera(player)

func borrow_camera(player, cutscene_node):
	is_cutscene = true
	game_params.get_hud().show_game_ui(false)
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

func restore_camera(player):
	var player_camera_holder = player.get_cam_holder()
	var camera = cutscene_node.get_child(0) if cutscene_node else player_camera_holder.get_child(0)
	if cutscene_node:
		player.reset_movement_and_rotation()
		player.set_simple_mode(true)
		cutscene_node.remove_child(camera)
		player_camera_holder.add_child(camera)
		camera.enable_use(true)
		cutscene_node = null
	camera.enable_use(true)
	game_params.get_hud().show_game_ui(true)
	is_cutscene = false

func get_cam():
	return cutscene_node.get_child(0) if cutscene_node and cutscene_node.get_child_count() > 0 else null

func is_cutscene():
	return is_cutscene