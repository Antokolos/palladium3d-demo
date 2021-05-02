tool
extends PLDUsable
class_name PLDDiscussable

const CONVERSATIONS_DELIMITER = ";"
const ACTION_KEY_DEFAULT = "ACTION_DISCUSS"
const ACTION_KEY_DEFAULT_SOLO = "ACTION_EXAMINE"

export(Dictionary) var conversations = {}
export(Dictionary) var action_keys = {}
export(NodePath) var cutscene_node_path = null
export(bool) var repeatable = true
export(bool) var discussable_with_self = false

onready var cutscene_node = get_node(cutscene_node_path) if cutscene_node_path and has_node(cutscene_node_path) else null

func _ready():
	for name_hint in CHARS.get_all_name_hints():
		if not conversations.has(name_hint):
			conversations[name_hint] = ""
		if not action_keys.has(name_hint):
			action_keys[name_hint] = ""

func get_action_key(pl):
	if Engine.editor_hint:
		return ACTION_KEY_DEFAULT
	var c = game_state.get_companion()
	var name_hint = c.get_name_hint() if c else pl.get_name_hint()
	if not action_keys.has(name_hint) \
		or action_keys[name_hint].empty():
		return ACTION_KEY_DEFAULT if c else ACTION_KEY_DEFAULT_SOLO
	return action_keys[name_hint]

func is_conversation_enabled(player_node, name_hint, conversation_idx):
	return true

func is_conversation_finished_or_not_applicable(player_node):
	if Engine.editor_hint:
		return true
	var player_name_hint = player_node.get_name_hint()
	for name_hint in conversations.keys():
		if conversations[name_hint].empty() \
			or not game_state.is_in_party(name_hint) \
			or ((name_hint.casecmp_to(player_name_hint) == 0) and not discussable_with_self):
			continue
		var conversations_for_name = conversations[name_hint].split(CONVERSATIONS_DELIMITER)
		for i in range(conversations_for_name.size()):
			if not is_conversation_enabled(player_node, name_hint, i):
				continue
			if repeatable:
				return false
			var conversation = conversations_for_name[i]
			return conversation_manager.conversation_is_finished(conversation)
	return true

func use(player_node, camera_node):
	if Engine.editor_hint:
		return
	if is_conversation_finished_or_not_applicable(player_node):
		return
	.use(player_node, camera_node)
	for name_hint in conversations.keys():
		if conversations[name_hint].empty() or not game_state.is_in_party(name_hint):
			continue
		var conversations_for_name = conversations[name_hint].split(CONVERSATIONS_DELIMITER)
		for i in range(conversations_for_name.size()):
			if not is_conversation_enabled(player_node, name_hint, i):
				continue
			var conversation = conversations_for_name[i]
			if cutscene_node:
				conversation_manager.start_area_cutscene(conversation, cutscene_node, repeatable)
			else:
				conversation_manager.start_area_conversation(conversation, repeatable)
			return

func get_usage_code(player_node):
	return "" if is_conversation_finished_or_not_applicable(player_node) else get_action_key(player_node)
