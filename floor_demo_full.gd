extends Spatial

func _on_AreaDeadEnd_body_entered(body):
	if body.is_in_group("party") and not game_params.conversation_dead_end:
		game_params.conversation_dead_end = true
		conversation_manager.start_conversation(get_node("/root/palladium/player"), "ink-scripts/DeadEnd.ink.json")

func _on_AreaApata_body_entered(body):
	if game_params.apata_on_pedestal and body.is_in_group("party") and not game_params.conversation_apata_statue:
		game_params.conversation_apata_statue = true
		conversation_manager.start_conversation(get_node("/root/palladium/player"), "ink-scripts/ApataStatue.ink.json")

func _on_AreaMuses_body_entered(body):
	if game_params.apata_in_chest and body.is_in_group("player") and not game_params.conversation_muses:
		game_params.conversation_muses = true
		conversation_manager.start_conversation(get_node("/root/palladium/player"), "ink-scripts/Muses.ink.json")

func _on_AreaApataDone_body_entered(body):
	if game_params.conversation_apata_statue and body.is_in_group("player") and not game_params.conversation_apata_done:
		game_params.conversation_apata_done = true
		conversation_manager.start_conversation(get_node("/root/palladium/player"), "ink-scripts/ApataDone.ink.json")
