extends MenuItem

onready var vase_over = get_parent().get_node("menu_vase_octopus_1")
onready var vase_out = get_parent().get_node("menu_vase_octopus_2")
onready var spotlight = get_parent().get_node("SpotLight")

func _ready():
	visible = TranslationServer.get_locale() != "ru"

func _on_StaticBody_input_event(camera, event, click_position, click_normal, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		game_params.scene_path = "res://our_games.tscn"
		get_tree().change_scene("res://scene_loader.tscn")

func _on_StaticBody_mouse_entered():
	mouse_over()
	vase_out.visible = false
	vase_over.visible = true
	spotlight.visible = true

func _on_StaticBody_mouse_exited():
	mouse_out()
	vase_over.visible = false
	vase_out.visible = true
	spotlight.visible = false
