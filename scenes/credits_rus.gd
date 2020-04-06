extends MenuItem

onready var spider = get_node("../../menu_spider")

func _on_StaticBody_input_event(camera, event, click_position, click_normal, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		game_params.get_hud().show_tablet(true, Tablet.ActivationMode.CREDITS)

func _on_StaticBody_mouse_entered():
	mouse_over()
	spider.spider_run()

func _on_StaticBody_mouse_exited():
	mouse_out()
	spider.spider_idle()
