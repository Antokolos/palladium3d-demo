extends PLDMenuItem

func click():
	game_state.get_hud().show_tablet(true, PLDTablet.ActivationMode.SETTINGS)

func mouse_over():
	.mouse_over()
	get_tree().call_group("fire_sources", "decrease_flame")
	get_tree().call_group("light_sources", "decrease_light")

func mouse_out():
	.mouse_out()
	get_tree().call_group("fire_sources", "restore_flame")
	get_tree().call_group("light_sources", "restore_light")
