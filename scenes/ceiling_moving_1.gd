extends Spatial

func activate():
	get_node("ceiling_armat000/AnimationPlayer").play("ceiling_action.000")

func pause():
	get_node("ceiling_armat000/AnimationPlayer").stop(false)

func deactivate():
	get_node("ceiling_armat000/AnimationPlayer").play_backwards("ceiling_action.000")

func restore_state():
	if game_params.story_vars.apata_trap_stage == game_params.ApataTrapStages.GOING_DOWN:
		activate()
	elif game_params.story_vars.apata_trap_stage == game_params.ApataTrapStages.PAUSED:
		activate()
		get_node("ceiling_armat000/AnimationPlayer").seek(20, true)
		pause()