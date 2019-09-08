extends StaticBody

func use(player_node):
	var hud = player_node.get_hud()
	if hud.inventory.visible:
		var item = hud.get_active_item()
		if item and item.nam.begins_with("statue_"):
			hud.inventory.visible = false
			item.remove()
			var inst = item.get_model_instance()
			inst.translate(Vector3(-0.05, 0.27, 0))
			inst.rotate_y(PI/2)
			inst.rotate_z(deg2rad(83))
			get_parent().add_child(inst)
			game_params.apata_in_chest = true

func add_highlight():
	#door_mesh.mesh.surface_set_material(surface_idx_door, null)
#	door_mesh.set_surface_material(surface_idx_door, outlined_material)
	return "E: Положить предмет в ларец (необходимо открыть инвентарь и выбрать предмет)"

func remove_highlight():
#	door_mesh.set_surface_material(surface_idx_door, null)
	#door_mesh.mesh.surface_set_material(surface_idx_door, material)
	pass