extends Spatial

onready var anim_player = get_node("speder_small_armature/AnimationPlayer")

func _on_Area_body_entered(body):
	if body.is_in_group("party"):
		$AnimationTree.set("parameters/Transition/current", 1)

func _on_Area_body_exited(body):
	if not game_state.is_loading() and body.is_in_group("party"):
		$AnimationTree.set("parameters/Transition/current", 0)