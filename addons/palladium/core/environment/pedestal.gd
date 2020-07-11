extends PLDUseTarget
class_name PLDPedestal

signal use_pedestal(player_node, pedestal, item_nam)

enum PedestalIds {
	NONE = 0,
	APATA = 10,
	MUSES = 20,
	ERIDA_LOCK = 30,
	DEMO_HERMES = 40,
	DEMO_ARES = 50,
	HEBE_LOCK = 60,
	APHRODITE_LOCK = 70,
	HERA_LOCK = 80,
	ARTEMIS_LOCK = 90,
	APOLLO_LOCK = 100,
	HERMES_FLAT = 110,
	ERIS_FLAT = 120,
	ARES_FLAT = 130,
	HEBE_FLAT = 140,
	SWORD = 150,
	ARTEMIS_TRAP = 160,
	ARTEMIS_APHRODITE = 160,
	APOLLO_STATUE = 170,
	ARGUS_HERMES = 180
}
export(PedestalIds) var pedestal_id = PedestalIds.NONE

func connect_signals(level):
	connect("use_pedestal", level, "use_pedestal")

func use_action(player_node, item):
	make_present(item)
	emit_signal("use_pedestal", player_node, self, item.nam)
	return true

func is_empty():
	for ch in get_children():
		if ch is PLDTakable:
			if ch.is_present():
				return false
	return true

func is_present(item_nam):
	for ch in get_children():
		if ch is PLDTakable:
			if ch.get_item_name() == item_nam and ch.is_present():
				return true
	return false

func make_present(item):
	for ch in get_children():
		if ch is PLDTakable:
			if ch.get_item_name() == item.nam:
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
				# If some exclusive item is already present, return false even if the name matches
				return false
			result = result or (not ch.is_present() and ch.get_item_name() == item.nam)
	return result

func get_use_action_text():
	return tr("ACTION_PUT_1")
