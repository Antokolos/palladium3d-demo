extends MenuItem

onready var rat = get_node("../../rat")
onready var rat_cover = get_node("../../rat_cover")

func click():
	get_tree().notify_group("quit_dialog", MainLoop.NOTIFICATION_WM_QUIT_REQUEST)

func mouse_over():
	.mouse_over()
	rat.rest_sniff()
	rat_cover.cast_shadow = GeometryInstance.SHADOW_CASTING_SETTING_OFF

func mouse_out():
	.mouse_out()
	rat.rest()
	rat_cover.cast_shadow = GeometryInstance.SHADOW_CASTING_SETTING_DOUBLE_SIDED
