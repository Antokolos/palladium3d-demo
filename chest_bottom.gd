extends StaticBody

func use(player_node):
	var hud = player_node.get_hud()
	if hud.inventory.visible:
		var item = hud.get_active_item()
		if item and item.nam.begins_with("statue_"):
			hud.inventory.visible = false
			item.remove()
			var inst = item.get_model_instance()
			inst.translate(Vector3(-0.05, 0.4, 0))
			inst.rotate_y(PI/2)
			inst.rotate_z(deg2rad(83))
			get_parent().add_child(inst)
			game_params.story_vars.apata_in_chest = true

func add_highlight(player_node):
	#door_mesh.mesh.surface_set_material(surface_idx_door, null)
#	door_mesh.set_surface_material(surface_idx_door, outlined_material)
	var hud = player_node.get_hud()
	if hud.inventory.visible:
		var item = hud.get_active_item()
		if item and item.nam == "statue_apata":
			return "E: Положить статуэтку в ларец"
	return ""

func remove_highlight(player_node):
#	door_mesh.set_surface_material(surface_idx_door, null)
	#door_mesh.mesh.surface_set_material(surface_idx_door, material)
	pass