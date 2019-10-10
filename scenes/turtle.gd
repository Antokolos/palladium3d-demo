extends Spatial

func _ready():
	var player = get_node("Armature/AnimationPlayer")
	#player.get_animation("turtle_rest.001").set_loop(true)
	player.play("turtle_rest.001")