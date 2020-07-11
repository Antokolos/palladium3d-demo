extends PLDMenuItem

onready var spotlight = get_parent().get_node("SpotLight")

func click():
	game_params.change_scene("res://forest.tscn")

func mouse_over():
	.mouse_over()
	spotlight.visible = true

func mouse_out():
	.mouse_out()
	spotlight.visible = false
