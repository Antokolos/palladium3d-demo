extends Node
class_name PLDCutsceneManager

signal camera_borrowed(player_node, cutscene_node, camera, conversation_name, target)
signal camera_restored(player_node, cutscene_node, camera, conversation_name, target)

var cutscene_node = null
var conversation_name = null
var target = null
var is_cutscene = false

func _ready():
	conversation_manager.connect("conversation_finished", self, "_on_conversation_finished")

func _on_conversation_finished(player, conversation_name, target, initiator, last_result):
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

func play_companion_cutscene(companions_map):
	for name_hint in companions_map.keys():
		if game_state.is_in_party(name_hint):
			var character = game_state.get_character(name_hint)
			character.play_cutscene(companions_map[name_hint])
			return

func borrow_camera(player, cutscene_node, is_hideout = false):
	is_cutscene = true
	game_state.get_hud().show_game_ui(false)
	var player_camera_holder = player.get_cam_holder()
	if player_camera_holder.get_child_count() == 0:
		# Do nothing if player has no camera. It looks like we are in cutscene already.
		return
	var camera = player_camera_holder.get_child(0)
	if not is_hideout:
		camera.enable_use(false)
		camera.show_cutscene_flashlight(true)
	self.cutscene_node = cutscene_node
	if not cutscene_node:
		return
	player.reset_rotation()
	player.set_simple_mode(false)
	player_camera_holder.remove_child(camera)
	cutscene_node.add_child(camera)
	emit_signal("camera_borrowed", player, cutscene_node, camera, conversation_name, target)

func restore_camera(player, conversation_name_prev = null, target_prev = null):
	var player_camera_holder = player.get_cam_holder()
	var cutscene_cam = get_cam()
	if cutscene_cam:
		player.reset_movement_and_rotation()
		player.set_simple_mode(true)
		cutscene_node.remove_child(cutscene_cam)
		player_camera_holder.add_child(cutscene_cam)
		cutscene_cam.show_cutscene_flashlight(false)
		cutscene_cam.enable_use(true)
		emit_signal("camera_restored", player, cutscene_node, cutscene_cam, conversation_name_prev, target_prev)
	elif player_camera_holder and player_camera_holder.get_child_count() > 0:
		var camera = player_camera_holder.get_child(0)
		camera.show_cutscene_flashlight(false)
		camera.enable_use(true)
	game_state.get_hud().show_game_ui(true)
	clear_cutscene_node()

# When borrowing camera in game, you should always use restore_camera()
# But sometimes it is needed to just clear cutscene node (for example, if your game is finished with a cutscene)
func clear_cutscene_node():
	cutscene_node = null
	target = null
	is_cutscene = false

func cutscene_node_is(node):
	if not node and not cutscene_node:
		return true
	if not node and cutscene_node:
		return false
	if node and not cutscene_node:
		return false
	return node.get_instance_id() == cutscene_node.get_instance_id()

func get_cam():
	return cutscene_node.get_child(0) if cutscene_node and cutscene_node.get_child_count() > 0 else null

func is_cutscene():
	return is_cutscene