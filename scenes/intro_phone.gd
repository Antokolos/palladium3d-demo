extends Spatial

func phone_idle():
	get_node("Armature/AnimationPlayer").play("phone_idle")

func phone_put_down():
	get_node("Armature/AnimationPlayer").play("phone_being_put_down")