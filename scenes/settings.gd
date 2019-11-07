extends MenuItem

func _ready():
	visible = TranslationServer.get_locale() != "ru"

func _on_StaticBody_input_event(camera, event, click_position, click_normal, shape_idx):
	pass # Replace with function body.

func _on_StaticBody_mouse_entered():
	mouse_over()
	get_tree().call_group("fire_sources", "decrease_flame")
	get_tree().call_group("light_sources", "decrease_light")

func _on_StaticBody_mouse_exited():
	mouse_out()
	get_tree().call_group("fire_sources", "restore_flame")
	get_tree().call_group("light_sources", "restore_light")
