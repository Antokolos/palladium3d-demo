extends StaticBody

export var item_name = "statue_urania"
export var model_path = "res://scenes/statue_1.tscn"
export var level_path = "../../../.."

func use(player_node):
	player_node.take(item_name, model_path)
	get_parent().queue_free()
	if item_name == "statue_apata":
		game_params.story_vars.apata_in_chest = false
		if game_params.story_vars.apata_on_pedestal:
			var level = get_node(level_path)
			level.get_door("door_0").close()
			level.get_node("ceiling_moving_1").activate()
			conversation_manager.start_conversation(player_node, get_node(game_params.companion_path), "ApataTrap")
		game_params.story_vars.apata_on_pedestal = false
	elif item_name == "statue_hermes":
		var level = get_node(level_path)
		level.get_door("door_5").activate()
		level.get_door("door_8").activate()

func add_highlight(player_node):
	#door_mesh.mesh.surface_set_material(surface_idx_door, null)
#	door_mesh.set_surface_material(surface_idx_door, outlined_material)
	return "E: Взять"

func remove_highlight(player_node):
#	door_mesh.set_surface_material(surface_idx_door, null)
	#door_mesh.mesh.surface_set_material(surface_idx_door, material)
	pass