extends PLDCamera

onready var anim_player = get_node("AnimationPlayer")

func rebuild_exceptions(player_node):
	pass

func enable_use(enable):
	pass

func _process(delta):
	pass

func _input(event):
	pass

func run_camera_1():
	anim_player.play("camera_1")

func run_camera_2():
	anim_player.play("camera_2")

func run_camera_3():
	anim_player.play("camera_3")