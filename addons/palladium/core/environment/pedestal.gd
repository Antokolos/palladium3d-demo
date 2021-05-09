extends PLDUseTarget
class_name PLDPedestal

signal use_pedestal(player_node, pedestal, inventory_item, child_item)

export(PLDDB.PedestalIds) var pedestal_id = PLDDB.PedestalIds.NONE

func connect_signals(target):
	connect("use_pedestal", target, "use_pedestal")

func use_action(player_node, item):
	var child_item = make_present(item)
	emit_signal("use_pedestal", player_node, self, item, child_item)
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

func is_item_id_matches(item, id):
	return item.item_id == id

func make_present(item):
	var child_made_present = null
	for ch in get_children():
		if ch is PLDTakable:
			if is_item_id_matches(item, ch.takable_id):
				ch.make_present()
				child_made_present = ch
			elif ch.is_exclusive():
				ch.make_absent()
	return child_made_present

func item_match(item):
	if not item:
		return false
	if .item_match(item):
		return true
	var result = false
	for ch in get_children():
		if ch is PLDTakable:
			if ch.is_present() and ch.is_exclusive():
				# If some exclusive item is already present, return false even if the item_id matches
				return false
			result = result or (not ch.is_present() and is_item_id_matches(item, ch.takable_id))
	return result

func get_use_action_code(player_node, item):
	return "ACTION_PUT_1"
