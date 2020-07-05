extends StaticBody
class_name Pedestal

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

func use(player_node, camera_node):
	var hud = game_params.get_hud()
	if hud and hud.get_active_item():
		var item = hud.get_active_item()
		if not item_match(item):
			return
		hud.inventory.visible = false
		item.used(player_node, self)
		item.remove()
		make_present(item)
		emit_signal("use_pedestal", player_node, self, item.nam)

func is_empty():
	for ch in get_children():
		if ch is Takable:
			if ch.is_present():
				return false
	return true

func is_present(item_nam):
	for ch in get_children():
		if ch is Takable:
			if ch.get_item_name() == item_nam and ch.is_present():
				return true
	return false

func make_present(item):
	for ch in get_children():
		if ch is Takable:
			if ch.get_item_name() == item.nam:
				ch.make_present()
			elif ch.is_exclusive():
				ch.make_absent()

func item_match(item):
	if not item:
		return false
	var result = false
	for ch in get_children():
		if ch is Takable:
			if ch.is_present() and ch.is_exclusive():
				# If some exclusive item is already present, return false even if the name matches
				return false
			result = result or (not ch.is_present() and ch.get_item_name() == item.nam)
	return result

func add_highlight(player_node):
	#door_mesh.mesh.surface_set_material(surface_idx_door, null)
#	door_mesh.set_surface_material(surface_idx_door, outlined_material)
	var hud = game_params.get_hud()
	if hud and hud.get_active_item():
		var item = hud.get_active_item()
		if item_match(item):
			return "E: " + tr("ACTION_PUT_1")
	return ""

func remove_highlight(player_node):
#	door_mesh.set_surface_material(surface_idx_door, null)
	#door_mesh.mesh.surface_set_material(surface_idx_door, material)
	pass