tool
extends Area
class_name PLDConversationArea

const CONVERSATIONS_DELIMITER = ";"

export(Dictionary) var conversations = {}
export(NodePath) var cutscene_node_path = null
export(bool) var repeatable = false

onready var cutscene_node = get_node(cutscene_node_path) if cutscene_node_path and has_node(cutscene_node_path) else null

func _ready():
	for name_hint in CHARS.get_all_name_hints():
		if not conversations.has(name_hint):
			conversations[name_hint] = ""
	if Engine.editor_hint:
		return
	conversation_manager.connect("conversation_finished", self, "_on_conversation_finished")
	cutscene_manager.connect("camera_borrowed", self, "_on_camera_borrowed")
	cutscene_manager.connect("camera_restored", self, "_on_camera_restored")

func is_conversation_enabled(name_hint, conversation_idx):
	return true

func _on_conversation_area_body_entered(body):
	if Engine.editor_hint:
		return false
	if not body.is_in_group("party") or game_state.is_loading():
		return false
	for name_hint in conversations.keys():
		if conversations[name_hint].empty() or not game_state.is_in_party(name_hint):
			continue
		var conversations_for_name = conversations[name_hint].split(CONVERSATIONS_DELIMITER)
		for i in range(conversations_for_name.size()):
			if not is_conversation_enabled(name_hint, i):
				continue
			var conversation = conversations_for_name[i]
			if conversation_manager.conversation_is_finished(conversation):
				continue
			if cutscene_node:
				conversation_manager.start_area_cutscene(conversation, cutscene_node, repeatable)
			else:
				conversation_manager.start_area_conversation(conversation, repeatable)
			return true
	return false

func do_when_conversation_finished(name_hint, conversation_name):
	pass

func do_when_camera_borrowed(player_node, cutscene_node, name_hint, conversation_name):
	pass

func do_when_camera_restored(player_node, cutscene_node, name_hint, conversation_name):
	pass

func _on_conversation_finished(player, conversation_name, target, initiator):
	if Engine.editor_hint:
		return
	for name_hint in conversations.keys():
		if conversations[name_hint].empty():
			continue
		var conversations_for_name = conversations[name_hint].split(CONVERSATIONS_DELIMITER)
		for conversation in conversations_for_name:
			if conversation == conversation_name:
				do_when_conversation_finished(name_hint, conversation_name)
				return

func _on_camera_borrowed(player_node, cutscene_node, conversation_name, target):
	if Engine.editor_hint:
		return
	if not self.cutscene_node or not cutscene_node:
		return
	if self.cutscene_node.get_instance_id() != cutscene_node.get_instance_id():
		return
	for name_hint in conversations.keys():
		if conversations[name_hint].empty():
			continue
		var conversations_for_name = conversations[name_hint].split(CONVERSATIONS_DELIMITER)
		for conversation in conversations_for_name:
			if conversation == conversation_name:
				do_when_camera_borrowed(player_node, cutscene_node, name_hint, conversation_name)
				return

func _on_camera_restored(player_node, cutscene_node, conversation_name, target):
	if Engine.editor_hint:
		return
	if not self.cutscene_node or not cutscene_node:
		return
	if self.cutscene_node.get_instance_id() != cutscene_node.get_instance_id():
		return
	for name_hint in conversations.keys():
		if conversations[name_hint].empty():
			continue
		var conversations_for_name = conversations[name_hint].split(CONVERSATIONS_DELIMITER)
		for conversation in conversations_for_name:
			if conversation == conversation_name:
				do_when_camera_restored(player_node, cutscene_node, name_hint, conversation_name)
				return