extends StaticBody

export var level_path = "../../.."

func use(player_node):
	var hud = player_node.get_hud()
	if hud.inventory.visible:
		var item = hud.get_active_item()
		if item and item.nam.begins_with("statue_"):
			var level = get_node(level_path)
			hud.inventory.visible = false
			item.remove()
			var inst = item.get_model_instance()
			var aabb = item.get_aabb(inst)
			get_parent().add_child(inst)
			if aabb and aabb.position:
				inst.translate(Vector3(0, abs(aabb.position.y), 0))
			if item.nam == "statue_apata":
				if game_params.story_vars.hope_on_pedestal:
					level.get_node("door_3").open()
					level.get_node("ceiling_moving_1").pause()
					game_params.story_vars.apata_trap_stage = game_params.ApataTrapStages.PAUSED
				return
			var base = get_node("../..")
			var child
			var pedestal_theatre = base.get_node("pedestal_theatre")
			if not pedestal_theatre or pedestal_theatre.get_child_count() < 2:
				return
			for child in pedestal_theatre.get_children():
				if "statue_name" in child and child.statue_name != "statue_melpomene":
					return
			var pedestal_astronomy = base.get_node("pedestal_astronomy")
			if not pedestal_astronomy or pedestal_astronomy.get_child_count() < 2:
				return
			for child in pedestal_astronomy.get_children():
				if "statue_name" in child and child.statue_name != "statue_urania":
					return
			var pedestal_history = base.get_node("pedestal_history")
			if not pedestal_history or pedestal_history.get_child_count() < 2:
				return
			for child in pedestal_history.get_children():
				if "statue_name" in child and child.statue_name != "statue_clio":
					return
			level.get_door("door_4").activate()
			game_params.story_vars.apata_trap_stage = game_params.ApataTrapStages.DISABLED
			level.get_node("ceiling_moving_1").deactivate()
			level.get_node("door_3").close()
		elif item and item.nam == "sphere_for_postament_body":
			hud.inventory.visible = false
			item.remove()
			var inst = item.get_model_instance()
			get_parent().add_child(inst)
			game_params.story_vars.hope_on_pedestal = true

func add_highlight(player_node):
	#door_mesh.mesh.surface_set_material(surface_idx_door, null)
#	door_mesh.set_surface_material(surface_idx_door, outlined_material)
	var hud = player_node.get_hud()
	if hud.inventory.visible:
		var item = hud.get_active_item()
		if item and item.nam == "sphere_for_postament_body":
			return "E: Поставить сферу на постамент"
	return ""

func remove_highlight(player_node):
#	door_mesh.set_surface_material(surface_idx_door, null)
	#door_mesh.mesh.surface_set_material(surface_idx_door, material)
	pass