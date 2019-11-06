extends Spatial

export var doors_path = "../../doors/floor_demo_full"
onready var doors = get_node(doors_path)

func get_door(door_path):
	return doors.get_node(door_path)

func _on_AreaDeadEnd_body_entered(body):
	var player = game_params.get_player()
	var target = game_params.get_companion()
	if body.is_in_group("party") and conversation_manager.conversation_is_not_finished(player, target, "DeadEnd"):
		conversation_manager.start_conversation(player, target, "DeadEnd")

func _on_AreaApata_body_entered(body):
	var player = game_params.get_player()
	var target = game_params.get_companion()
	if game_params.story_vars.apata_trap_stage == game_params.ApataTrapStages.ARMED and body.is_in_group("party") and conversation_manager.conversation_is_not_finished(player, target, "ApataStatue"):
		conversation_manager.start_conversation(player, target, "ApataStatue")

func _on_AreaMuses_body_entered(body):
	var player = game_params.get_player()
	var target = game_params.get_companion()
	if game_params.story_vars.apata_trap_stage == game_params.ApataTrapStages.PAUSED and body.is_in_group("party") and body.is_player() and conversation_manager.conversation_is_not_finished(player, target, "Muses"):
		conversation_manager.start_conversation(player, target, "Muses")

func _on_AreaApataDone_body_entered(body):
	var player = game_params.get_player()
	var target = game_params.get_companion()
	if conversation_manager.conversation_is_finished(player, target, "ApataStatue") and body.is_in_group("party") and body.is_player() and conversation_manager.conversation_is_not_finished(player, target, "ApataDone"):
		conversation_manager.start_conversation(player, target, "ApataDone")