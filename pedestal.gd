extends StaticBody
class_name Pedestal

signal use_pedestal(player_node, pedestal, item_nam)

enum PedestalIds {
	NONE = 0,
	APATA = 10,
	MUSES = 20,
	ERIDA_LOCK = 30,
	DEMO_HERMES = 40,
	DEMO_ARES = 50
}
export(PedestalIds) var pedestal_id = PedestalIds.NONE

func connect_signals(level):
	connect("use_pedestal", level, "use_pedestal")

func use(player_node):
	var hud = player_node.get_hud()
	if hud and hud.get_active_item():
		var item = hud.get_active_item()
		if not item_match(item):
			return
		hud.inventory.visible = false
		item.remove()
		make_present(item)
		emit_signal("use_pedestal", player_node, self, item.nam)

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
	for ch in get_children():
		if (ch is Takable) and ch.get_item_name() == item.nam:
			return true
	return false

func add_highlight(player_node):
	#door_mesh.mesh.surface_set_material(surface_idx_door, null)
#	door_mesh.set_surface_material(surface_idx_door, outlined_material)
	var hud = player_node.get_hud()
	if hud and hud.get_active_item():
		var item = hud.get_active_item()
		if item_match(item):
			return "E: Поставить на постамент"
	return ""

func remove_highlight(player_node):
#	door_mesh.set_surface_material(surface_idx_door, null)
	#door_mesh.mesh.surface_set_material(surface_idx_door, material)
	pass