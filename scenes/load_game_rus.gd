extends MenuItem

onready var hud = get_node("../../menu_hud")

func _ready():
	visible = TranslationServer.get_locale() == "ru"

func _on_StaticBody_input_event(camera, event, click_position, click_normal, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		hud.show_tablet(true)

func _on_StaticBody_mouse_entered():
	mouse_over()
	get_parent().open()

func _on_StaticBody_mouse_exited():
	mouse_out()
	get_parent().close()
