extends MenuItem

onready var spider = get_node("../../menu_spider")
onready var spotlight = get_parent().get_node("SpotLight")

func _on_StaticBody_input_event(camera, event, click_position, click_normal, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		game_params.get_hud().show_tablet(true, Tablet.ActivationMode.CREDITS)

func _on_StaticBody_mouse_entered():
	mouse_over()
	spotlight.visible = true
	spider.spider_run()

func _on_StaticBody_mouse_exited():
	mouse_out()
	spotlight.visible = false
	spider.spider_idle()
