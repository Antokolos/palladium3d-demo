extends PLDUsable
class_name PLDLootable

signal use_lootable(player_node, lootable)

export(DB.TakableIds) var takable_id = DB.TakableIds.NONE
export(int) var count_init = 1
export(bool) var can_loot = true

func _ready():
	game_state.connect("item_taken", self, "_on_item_taken")

func connect_signals(target):
	connect("use_lootable", target, "use_lootable")

func use(player_node, camera_node):
	if not is_can_loot():
		return false
	game_state.take(takable_id, get_count(), get_path())
	emit_signal("use_lootable", player_node, self)
	return true

func add_highlight(player_node):
	return common_utils.get_action_input_control() + tr("ACTION_LOOT") if is_can_loot() else ""

func _on_item_taken(item_id, cnt, item_path):
	if item_id == takable_id and item_path == get_path():
		make_absent()

func has_id(tid):
	return takable_id == tid

func is_can_loot():
	return can_loot and is_present()

func get_count():
	return game_state.get_lootable_count(get_path())

func set_count(amount):
	game_state.set_lootable_count(get_path(), amount)

func inc_count(amount):
	var path = get_path()
	var count_new = game_state.get_lootable_count(path) + amount
	game_state.set_lootable_count(path, count_new)
	return count_new

func is_present():
	if takable_id == DB.TakableIds.NONE:
		return false
	var path = get_path()
	if game_state.get_lootable_count(path) <= 0:
		return false
	var ts = game_state.get_takable_state(path)
	return (ts == game_state.TakableState.DEFAULT) or (ts == game_state.TakableState.PRESENT)

func make_present():
	var path = get_path()
	game_state.set_takable_state(path, false)
	if game_state.get_lootable_count(path) <= 0:
		game_state.set_lootable_count(path, count_init)

func make_absent():
	var path = get_path()
	game_state.set_takable_state(path, true)
	game_state.set_lootable_count(path, 0)

func restore_state():
	var state = game_state.get_takable_state(get_path())
	if state == game_state.TakableState.DEFAULT:
		make_present()
		return
	if state == game_state.TakableState.PRESENT:
		make_present()
	else:
		make_absent()
