extends StaticBody

export var item_name = "statue_urania"
export var model_path = "res://scenes/statue_1.tscn"
export var level_path = "../../../.."

func use(player_node):
	player_node.take(item_name, model_path)
	get_parent().queue_free()
	if item_name == "statue_apata":
		game_params.apata_in_chest = false
		if game_params.apata_on_pedestal:
			var level = get_node(level_path)
			level.get_door("door_1").close()
			level.get_node("ceiling_moving_2").activate()
			conversation_manager.start_conversation(player_node, get_node(game_params.companion_path), "ApataTrap")
		game_params.apata_on_pedestal = false

func add_highlight():
	#door_mesh.mesh.surface_set_material(surface_idx_door, null)
#	door_mesh.set_surface_material(surface_idx_door, outlined_material)
	return "E: Взять"

func remove_highlight():
#	door_mesh.set_surface_material(surface_idx_door, null)
	#door_mesh.mesh.surface_set_material(surface_idx_door, material)
	pass