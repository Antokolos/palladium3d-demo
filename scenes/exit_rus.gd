extends MenuItem

onready var rat = get_node("../../rat")
onready var hud = get_node("../../menu_hud")

func _ready():
	visible = TranslationServer.get_locale() == "ru"

func _on_StaticBody_input_event(camera, event, click_position, click_normal, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		hud.ask_quit()

func _on_StaticBody_mouse_entered():
	mouse_over()
	rat.rest_sniff()

func _on_StaticBody_mouse_exited():
	mouse_out()
	rat.rest()
