extends Spatial

export var doors_path = "../../doors/floor_demo_full"
onready var doors = get_node(doors_path)

func get_door(door_path):
	return doors.get_node(door_path)

func _on_AreaDeadEnd_body_entered(body):
	if body.is_in_group("party") and not game_params.conversation_dead_end:
		game_params.conversation_dead_end = true
		conversation_manager.start_conversation(get_node(game_params.player_path), get_node(game_params.companion_path), "DeadEnd")

func _on_AreaApata_body_entered(body):
	if game_params.apata_on_pedestal and body.is_in_group("party") and not game_params.conversation_apata_statue:
		game_params.conversation_apata_statue = true
		conversation_manager.start_conversation(get_node(game_params.player_path), get_node(game_params.companion_path), "ApataStatue")

func _on_AreaMuses_body_entered(body):
	if game_params.apata_in_chest and body.is_in_group("party") and body.is_player() and not game_params.conversation_muses:
		game_params.conversation_muses = true
		conversation_manager.start_conversation(get_node(game_params.player_path), get_node(game_params.companion_path), "Muses")

func _on_AreaApataDone_body_entered(body):
	if game_params.conversation_apata_statue and body.is_in_group("party") and body.is_player() and not game_params.conversation_apata_done:
		game_params.conversation_apata_done = true
		conversation_manager.start_conversation(get_node(game_params.player_path), get_node(game_params.companion_path), "ApataDone")
