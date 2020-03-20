extends Spatial

func _ready():
	conversation_manager.connect("conversation_finished", self, "_on_conversation_finished")
	restore_state()

func restore_state():
	var meetingXeniaFinished = conversation_manager.conversation_is_finished(game_params.get_player(), "001_MeetingXenia")
	var meetingAndreasFinished = conversation_manager.conversation_is_finished(game_params.get_player(), "002_MeetingAndreas")
	if meetingXeniaFinished or meetingAndreasFinished:
		queue_free()

func _on_conversation_finished(player, target, conversation_name, is_cutscene):
	if conversation_name == "001_MeetingXenia" or conversation_name == "002_MeetingAndreas":
		print("DEBUG: Boat disappears")
		queue_free()