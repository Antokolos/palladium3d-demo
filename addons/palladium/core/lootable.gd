extends PLDUsable
class_name PLDLootable

signal use_lootable(player_node, lootable)

export(DB.TakableIds) var takable_id = DB.TakableIds.NONE
export(int) var count = 1

func _ready():
	game_state.connect("item_taken", self, "_on_item_taken")

func connect_signals(target):
	connect("use_lootable", target, "use_lootable")

func use(player_node, camera_node):
	if not is_present():
		return false
	game_state.take(takable_id, count, get_path())
	emit_signal("use_lootable", player_node, self)
	return true

func add_highlight(player_node):
	return "E: " + tr("ACTION_LOOT") if is_present() else ""

func _on_item_taken(item_id, cnt, item_path):
	if item_id == takable_id and item_path == get_path():
		make_absent()

func has_id(tid):
	return takable_id == tid

func is_present():
	if takable_id == DB.TakableIds.NONE:
		return false
	var ts = game_state.get_takable_state(get_path())
	return (ts == game_state.TakableState.DEFAULT) or (ts == game_state.TakableState.PRESENT)

func make_present():
	game_state.set_takable_state(get_path(), false)

func make_absent():
	game_state.set_takable_state(get_path(), true)

func restore_state():
	var state = game_state.get_takable_state(get_path())
	if state == game_state.TakableState.DEFAULT:
		make_present()
		return
	if state == game_state.TakableState.PRESENT:
		make_present()
	else:
		make_absent()
