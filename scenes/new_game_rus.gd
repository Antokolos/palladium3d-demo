extends MenuItem

onready var spotlight = get_parent().get_node("SpotLight")

func _ready():
	visible = TranslationServer.get_locale() == "ru"

func _on_StaticBody_input_event(camera, event, click_position, click_normal, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		game_params.scene_path = "res://forest.tscn"
		get_tree().change_scene("res://scene_loader.tscn")

func _on_StaticBody_mouse_entered():
	mouse_over()
	spotlight.visible = true

func _on_StaticBody_mouse_exited():
	mouse_out()
	spotlight.visible = false
