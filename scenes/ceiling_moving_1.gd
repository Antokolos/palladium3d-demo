extends Spatial

func activate():
	get_node("ceiling_armat000/AnimationPlayer").play("ceiling_action.000")

func pause():
	get_node("ceiling_armat000/AnimationPlayer").stop(false)

func deactivate():
	get_node("ceiling_armat000/AnimationPlayer").play_backwards("ceiling_action.000")
