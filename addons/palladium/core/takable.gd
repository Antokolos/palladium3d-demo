extends PLDUsable
class_name PLDTakable

signal use_takable(player_node, takable, parent, was_taken)

export(DB.TakableIds) var takable_id = DB.TakableIds.NONE
# if exclusive == true, then this item should not be present at the same time as the another items on the same pedestal or in the same container
export var exclusive = true

onready var initially_present = visible

func _ready():
	restore_state()
	game_state.connect("item_taken", self, "_on_item_taken")
	game_state.connect("item_removed", self, "_on_item_removed")

func connect_signals(level):
	connect("use_takable", level, "use_takable")

func get_item_name():
	return DB.get_item_name(takable_id)

func use(player_node, camera_node):
#	if takable_id == DB.TakableIds.APATA and player_node.is_player() and game_state.story_vars.apata_trap_stage == game_state.ApataTrapStages.ARMED:
#		# Cannot be taken by the main player if Apata's trap has not been activated yet
#		return false
	var was_taken = is_present()
	game_state.take(get_item_name(), get_path())
	emit_signal("use_takable", player_node, self, get_parent(), was_taken)
	return was_taken

func add_highlight(player_node):
#	if takable_id == DB.TakableIds.APATA and game_state.story_vars.apata_trap_stage == game_state.ApataTrapStages.ARMED:
#		return ""
	return "E: " + tr("ACTION_TAKE") if is_present() else ""

func _on_item_taken(nam, cnt, item_path):
	if nam == get_item_name() and item_path == get_path():
		make_absent()

func _on_item_removed(nam, cnt):
	# TODO: make present??? Likely it is handled in containers...
	if has_node("SoundPut"):
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
