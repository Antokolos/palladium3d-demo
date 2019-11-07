extends MenuItem

onready var spider = get_node("../../menu_spider")

func _ready():
	visible = TranslationServer.get_locale() != "ru"

func _on_StaticBody_input_event(camera, event, click_position, click_normal, shape_idx):
	pass # Replace with function body.

func _on_StaticBody_mouse_entered():
	mouse_over()
	spider.spider_run()

func _on_StaticBody_mouse_exited():
	mouse_out()
	spider.spider_idle()
