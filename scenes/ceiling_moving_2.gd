extends Spatial

func activate():
	get_node("ceiling_armat002/AnimationPlayer").play("ceiling_action.003", -1, 0.2)
	get_node("GameOverTimer").start()

func deactivate():
	get_node("ceiling_armat002/AnimationPlayer").play_backwards("ceiling_action.003")
	get_node("GameOverTimer").stop()

func _on_GameOverTimer_timeout():
	return get_tree().change_scene("res://game_over.tscn")
