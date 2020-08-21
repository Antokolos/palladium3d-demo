tool
extends PLDUsable
class_name PLDReadable

const CONVERSATIONS_DELIMITER = ";"

export(Dictionary) var conversations = {}
export(NodePath) var cutscene_node_path = null

onready var cutscene_node = get_node(cutscene_node_path) if cutscene_node_path and has_node(cutscene_node_path) else null

func _ready():
	for name_hint in DB.PARTY_DEFAULT.keys():
		if not conversations.has(name_hint):
			conversations[name_hint] = ""

func is_conversation_enabled(player_node, name_hint, conversation_idx):
	return true

func use(player_node, camera_node):
	if Engine.editor_hint:
		return
	for name_hint in conversations.keys():
		if conversations[name_hint].empty() or not game_state.party[name_hint]:
			continue
		var conversations_for_name = conversations[name_hint].split(CONVERSATIONS_DELIMITER)
		for i in range(conversations_for_name.size()):
			if not is_conversation_enabled(player_node, name_hint, i):
				continue
			var conversation = conversations_for_name[i]
			if cutscene_node:
				.use(player_node, camera_node)
				conversation_manager.start_area_cutscene(conversation, cutscene_node, true)
			else:
				.use(player_node, camera_node)
				conversation_manager.start_area_conversation(conversation, true)
			return

func add_highlight(player_node):
	if Engine.editor_hint:
		return ""
	for name_hint in conversations.keys():
		if conversations[name_hint].empty() or not game_state.party[name_hint]:
			continue
		var conversations_for_name = conversations[name_hint].split(CONVERSATIONS_DELIMITER)
		for i in range(conversations_for_name.size()):
			if not is_conversation_enabled(player_node, name_hint, i):
				continue
			return "E: " + tr("ACTION_READ")
	return ""
