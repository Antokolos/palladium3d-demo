extends MenuItem

onready var hud = get_node("../menu_hud")

func _ready():
	visible = TranslationServer.get_locale() != "ru"

func _on_StaticBody_input_event(camera, event, click_position, click_normal, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		hud.show_tablet(true, Tablet.ActivationMode.SETTINGS)

func _on_StaticBody_mouse_entered():
	mouse_over()
	get_tree().call_group("fire_sources", "decrease_flame")
	get_tree().call_group("light_sources", "decrease_light")

func _on_StaticBody_mouse_exited():
	mouse_out()
	get_tree().call_group("fire_sources", "restore_flame")
	get_tree().call_group("light_sources", "restore_light")
