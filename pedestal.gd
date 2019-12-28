extends StaticBody

export var level_path = ".."
enum PedestalIds { NONE = 0, APATA = 1 }
export(PedestalIds) var pedestal_id = PedestalIds.NONE

func use(player_node):
	var hud = player_node.get_hud()
	if hud and hud.get_active_item():
		var item = hud.get_active_item()
		if not item_match(item):
			return
		if item and item.nam.begins_with("statue_"):
			var level = get_node(level_path)
			hud.inventory.visible = false
			item.remove()
			make_present(item)
			if item.nam == "statue_apata":
				if game_params.story_vars.hope_on_pedestal:
					level.get_node("door_3").open()
					level.get_node("ceiling_moving_1").pause()
					game_params.story_vars.apata_trap_stage = game_params.ApataTrapStages.PAUSED
				return
			if not check_muses_correct():
				return
			level.get_door("door_4").open()
			game_params.story_vars.apata_trap_stage = game_params.ApataTrapStages.DISABLED
			level.get_node("ceiling_moving_1").deactivate()
			level.get_node("door_3").close()
		elif item and item.nam == "sphere_for_postament_body":
			hud.inventory.visible = false
			item.remove()
			make_present(item)
			game_params.story_vars.hope_on_pedestal = true

func check_pedestal(pedestal, takable_id):
	var correct = false
	if not pedestal:
		return false
	for ch in pedestal.get_children():
		if (ch is Takable) and ch.is_present():
			if ch.has_id(takable_id):
				correct = true
			else:
				return false
	return correct

func check_muses_correct():
	var base = get_node("..")
	var pedestal_theatre = base.get_node("pedestal_theatre")
	if not check_pedestal(pedestal_theatre, Takable.TakableIds.MELPOMENE):
		return false
	var pedestal_astronomy = base.get_node("pedestal_astronomy")
	if not check_pedestal(pedestal_astronomy, Takable.TakableIds.URANIA):
		return false
	var pedestal_history = base.get_node("pedestal_history")
	return check_pedestal(pedestal_history, Takable.TakableIds.CLIO)

func make_present(item):
	for ch in get_children():
		if ch is Takable:
			if ch.get_item_name() == item.nam:
				ch.make_present()
			elif ch.is_exclusive():
				ch.make_absent()

func item_match(item):
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