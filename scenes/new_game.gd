extends PLDMenuItem

onready var spotlight = get_parent().get_node("SpotLight")

func click():
	game_state.change_scene("res://intro_full.tscn")

func mouse_over():
	.mouse_over()
	spotlight.visible = true

func mouse_out():
	.mouse_out()
	spotlight.visible = false
