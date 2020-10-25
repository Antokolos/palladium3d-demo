extends Spatial

func _ready():
	conversation_manager.connect("meeting_finished", self, "_on_meeting_finished")

func restore_state():
	if conversation_manager.meeting_is_finished(CHARS.FEMALE_NAME_HINT, CHARS.PLAYER_NAME_HINT):
		queue_free()

func _on_meeting_finished(player, target, initiator):
	print("DEBUG: Boat disappears")
	queue_free()