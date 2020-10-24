extends Spatial

func open():
	get_node("door_3_arm/AnimationPlayer").play("door_3")
	get_node("StaticBody/CollisionShape").disabled = true

func close():
	get_node("door_3_arm/AnimationPlayer").play_backwards("door_3")
	get_node("StaticBody/CollisionShape").disabled = false

func restore_state():
	if game_state.get_activatable_state_by_id(DB.ActivatableIds.APATA_TRAP) == PLDGameState.ActivatableState.PAUSED:
		open()