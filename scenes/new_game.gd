extends PLDMenuItem

onready var spotlight = get_parent().get_node("SpotLight")

func click():
	game_state.get_hud().show_difficulty_dialog()

func mouse_over():
	.mouse_over()
	spotlight.visible = true

func mouse_out():
	.mouse_out()
	spotlight.visible = false
