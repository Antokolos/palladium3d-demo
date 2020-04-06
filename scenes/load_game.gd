extends MenuItem

func _on_StaticBody_input_event(camera, event, click_position, click_normal, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		game_params.get_hud().show_tablet(true, Tablet.ActivationMode.LOAD)

func _on_StaticBody_mouse_entered():
	mouse_over()
	get_parent().open()

func _on_StaticBody_mouse_exited():
	mouse_out()
	get_parent().close()
