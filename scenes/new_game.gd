extends PLDMenuItem

onready var spotlight = get_parent().get_node("SpotLight")

func click():
	game_params.scene_path = "res://forest.tscn"
	get_tree().change_scene("res://addons/palladium/ui/scene_loader.tscn")

func mouse_over():
	.mouse_over()
	spotlight.visible = true

func mouse_out():
	.mouse_out()
	spotlight.visible = false
