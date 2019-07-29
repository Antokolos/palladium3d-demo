extends Spatial

func activate():
	get_node("stone_door_2_armature/AnimationPlayer").play("door_1.001")
	get_node("StaticBody/closed_door").disabled = true
	get_node("../ceiling_moving_2").deactivate()
	get_node("../door_3").close()