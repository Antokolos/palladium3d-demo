extends StaticBody

export var item_name = "statue_urania"
export var model_path = "res://scenes/statue_1.tscn"

func use(player_node):
	player_node.take(item_name, model_path)
	get_parent().queue_free()
	if item_name == "statue_apata":
		game_params.apata_in_chest = false
		if game_params.apata_on_pedestal:
			get_node("../../../../door_1").close()
			get_node("../../../../ceiling_moving_2").activate()
			conversation_manager.start_conversation(get_node("/root/palladium/player"), "ink-scripts/ApataTrap.ink.json")
		game_params.apata_on_pedestal = false

func add_highlight():
	#door_mesh.mesh.surface_set_material(surface_idx_door, null)
#	door_mesh.set_surface_material(surface_idx_door, outlined_material)
	return "E: Взять"

func remove_highlight():
#	door_mesh.set_surface_material(surface_idx_door, null)
	#door_mesh.mesh.surface_set_material(surface_idx_door, material)
	pass