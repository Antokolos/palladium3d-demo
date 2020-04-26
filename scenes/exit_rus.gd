extends MenuItem

onready var rat = get_node("../../rat")
onready var rat_cover = get_node("../../rat_cover")

func _on_StaticBody_input_event(camera, event, click_position, click_normal, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		get_tree().notify_group("quit_dialog", MainLoop.NOTIFICATION_WM_QUIT_REQUEST)

func _on_StaticBody_mouse_entered():
	mouse_over()
	rat.rest_sniff()
	rat_cover.cast_shadow = GeometryInstance.SHADOW_CASTING_SETTING_OFF

func _on_StaticBody_mouse_exited():
	mouse_out()
	rat.rest()
	rat_cover.cast_shadow = GeometryInstance.SHADOW_CASTING_SETTING_DOUBLE_SIDED
