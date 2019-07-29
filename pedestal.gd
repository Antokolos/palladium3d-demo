extends StaticBody

func use(player_node):
	if player_node.inventory.visible:
		var item = player_node.get_active_item()
		if item and item.nam.begins_with("statue_"):
			player_node.inventory.visible = false
			item.remove()
			get_parent().add_child(item.get_model_instance())
			if item.nam == "statue_apata":
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
			get_node("../../../door_2").activate()

func add_highlight():
	#door_mesh.mesh.surface_set_material(surface_idx_door, null)
#	door_mesh.set_surface_material(surface_idx_door, outlined_material)
	return "E: Поставить предмет на пьедестал" if get_child_count() == 0 else ""

func remove_highlight():
#	door_mesh.set_surface_material(surface_idx_door, null)
	#door_mesh.mesh.surface_set_material(surface_idx_door, material)
	pass