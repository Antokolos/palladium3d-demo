extends Spatial

func activate():
	get_node("door_4_armature/AnimationPlayer").play("door_4_armatureAction")
	get_node("StaticBody/CollisionShape").disabled = true
	get_node("../ceiling_moving_2").deactivate()
	get_node("../door_3").close()