tool
extends Area
class_name PLDConversationArea

export(Dictionary) var conversations = {}
export(NodePath) var cutscene_node_path = null

onready var cutscene_node = get_node(cutscene_node_path) if cutscene_node_path and has_node(cutscene_node_path) else null

func _ready():
	for name_hint in DB.PARTY_DEFAULT.keys():
		if not conversations.has(name_hint):
			conversations[name_hint] = ""

func is_conversation_enabled():
	return true

func _on_conversation_area_body_entered(body):
	if Engine.editor_hint:
		return
	if not is_conversation_enabled():
		return
	if body.is_in_group("party") and not game_state.is_loading():
		for name_hint in conversations.keys():
			var conversation = conversations[name_hint]
			if not conversation.empty() and game_state.party[name_hint]:
				if cutscene_node:
					conversation_manager.start_area_cutscene(conversation, cutscene_node)
				else:
					conversation_manager.start_area_conversation(conversation)
				return
