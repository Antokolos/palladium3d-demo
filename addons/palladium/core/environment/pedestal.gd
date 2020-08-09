extends PLDUseTarget
class_name PLDPedestal

signal use_pedestal(player_node, pedestal, item_id)

export(DB.PedestalIds) var pedestal_id = DB.PedestalIds.NONE

func connect_signals(target):
	connect("use_pedestal", target, "use_pedestal")

func use_action(player_node, item):
	make_present(item)
	emit_signal("use_pedestal", player_node, self, item.item_id)
	return true

func is_empty():
	for ch in get_children():
		if ch is PLDTakable:
			if ch.is_present():
				return false
	return true

func is_present(item_id):
	for ch in get_children():
		if ch is PLDTakable:
			if ch.takable_id == item_id and ch.is_present():
				return true
	return false

func make_present(item):
	for ch in get_children():
		if ch is PLDTakable:
			if ch.takable_id == item.item_id:
				ch.make_present()
			elif ch.is_exclusive():
				ch.make_absent()

func item_match(item):
	if not item:
		return false
	var result = false
	for ch in get_children():
		if ch is PLDTakable:
			if ch.is_present() and ch.is_exclusive():
				# If some exclusive item is already present, return false even if the item_id matches
				return false
			result = result or (not ch.is_present() and ch.takable_id == item.item_id)
	return result

func get_use_action_text():
	return tr("ACTION_PUT_1")
