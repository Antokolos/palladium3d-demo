extends StaticBody

func use(player_node):
	game_params.scene_path = "res://forest.tscn"
	get_tree().change_scene("res://scene_loader.tscn")

func add_highlight(player_node):
	#door_mesh.mesh.surface_set_material(surface_idx_door, null)
#	door_mesh.set_surface_material(surface_idx_door, outlined_material)
	return "E: " + tr("ACTION_GO_OUTSIDE")

func remove_highlight(player_node):
#	door_mesh.set_surface_material(surface_idx_door, null)
	#door_mesh.mesh.surface_set_material(surface_idx_door, material)
	pass