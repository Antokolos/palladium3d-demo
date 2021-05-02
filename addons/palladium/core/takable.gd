extends PLDUsable
class_name PLDTakable

signal use_takable(player_node, takable, parent, was_taken)

export(DB.TakableIds) var takable_id = DB.TakableIds.NONE
# if exclusive == true, then this item should not be present at the same time as the another items on the same pedestal or in the same container
export var exclusive = true

onready var initially_present = visible

func _ready():
	game_state.connect("item_taken", self, "_on_item_taken")
	game_state.connect("item_removed", self, "_on_item_removed")

func connect_signals(target):
	connect("use_takable", target, "use_takable")

func use(player_node, camera_node):
	var was_taken = is_present()
	game_state.take(takable_id, 1, get_path())
	emit_signal("use_takable", player_node, self, get_parent(), was_taken)
	return was_taken

func get_usage_code(player_node):
	return "ACTION_TAKE" if is_present() else ""

func _on_item_taken(item_id, count_total, count_taken, item_path):
	if has_id(item_id) and item_path == get_path():
		make_absent()

func _on_item_removed(item_id, count_total, count_removed):
	# TODO: make present??? Likely it is handled in containers...
	if has_id(item_id) and has_node("SoundPut"):
		$SoundPut.play()

func has_id(tid):
	return takable_id == tid

func is_exclusive():
	return exclusive

func is_present():
	var ts = game_state.get_takable_state(get_path())
	return (ts == game_state.TakableState.DEFAULT and initially_present) or (ts == game_state.TakableState.PRESENT)

func enable_collisions(enable):
	for ch in get_children():
		if ch is CollisionShape:
			ch.disabled = not enable

func make_present():
	visible = true
	enable_collisions(true)
	game_state.set_takable_state(get_path(), false)

func make_absent():
	visible = false
	enable_collisions(false)
	game_state.set_takable_state(get_path(), true)

func restore_state():
	var state = game_state.get_takable_state(get_path())
	if state == game_state.TakableState.DEFAULT:
		if initially_present:
			make_present()
		else:
			make_absent()
		return
	if state == game_state.TakableState.PRESENT:
		make_present()
	else:
		make_absent()
