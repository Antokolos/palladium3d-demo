extends PLDMenuItem

onready var vase_over = get_parent().get_node("menu_vase_octopus_1")
onready var vase_out = get_parent().get_node("menu_vase_octopus_2")
onready var spotlight = get_parent().get_node("SpotLight")

func click():
	game_state.change_scene("res://our_games.tscn")

func mouse_over():
	.mouse_over()
	vase_out.visible = false
	vase_over.visible = true
	spotlight.visible = true

func mouse_out():
	.mouse_out()
	vase_over.visible = false
	vase_out.visible = true
	spotlight.visible = false
