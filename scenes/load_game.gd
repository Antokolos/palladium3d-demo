extends PLDMenuItem

func click():
	game_params.get_hud().show_tablet(true, PLDTablet.ActivationMode.LOAD)

func mouse_over():
	.mouse_over()
	get_parent().open()

func mouse_out():
	.mouse_out()
	get_parent().close()
