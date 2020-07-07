extends PLDMenuItem

onready var spider = get_node("../../menu_spider")
onready var spotlight = get_parent().get_node("SpotLight")

func click():
	game_params.get_hud().show_tablet(true, PLDTablet.ActivationMode.CREDITS)

func mouse_over():
	.mouse_over()
	spotlight.visible = true
	spider.spider_run()

func mouse_out():
	.mouse_out()
	spotlight.visible = false
	spider.spider_idle()
