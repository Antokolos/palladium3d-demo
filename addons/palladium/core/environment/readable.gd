tool
extends PLDDiscussable
class_name PLDReadable

func get_action_key(pl):
	if Engine.editor_hint:
		return ACTION_KEY_DEFAULT
	if pl.can_read():
		return "ACTION_READ"
	var c = game_state.get_companion()
	if c and c.can_read():
		return "ACTION_READ_ASK"
	return .get_action_key(pl)
