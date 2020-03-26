extends Spatial

func _ready():
	conversation_manager.connect("conversation_finished", self, "_on_conversation_finished")
	restore_state()

func activate():
	game_params.story_vars.apata_trap_stage = game_params.ApataTrapStages.GOING_DOWN
	get_node("ceiling_armat000/AnimationPlayer").play("ceiling_action.000")

func pause():
	game_params.story_vars.apata_trap_stage = game_params.ApataTrapStages.PAUSED
	get_node("ceiling_armat000/AnimationPlayer").stop(false)

func deactivate():
	game_params.story_vars.apata_trap_stage = game_params.ApataTrapStages.DISABLED
	get_node("ceiling_armat000/AnimationPlayer").play_backwards("ceiling_action.000")

func restore_state():
	if game_params.story_vars.apata_trap_stage == game_params.ApataTrapStages.GOING_DOWN:
		activate()
	elif game_params.story_vars.apata_trap_stage == game_params.ApataTrapStages.PAUSED:
		activate()
		get_node("ceiling_armat000/AnimationPlayer").seek(20, true)
		pause()

func _on_AnimationPlayer_animation_finished(anim_name):
	if game_params.story_vars.apata_trap_stage == GameParams.ApataTrapStages.GOING_DOWN and conversation_manager.conversation_is_finished(game_params.get_player(), "010-2-1_ChestMoved"):
		var bandit = game_params.get_character(game_params.BANDIT_NAME_HINT)
		var female = game_params.get_character(game_params.FEMALE_NAME_HINT)
		bandit.join_party()
		female.join_party()
		conversation_manager.start_area_conversation("010-2-2_CeilingStopped")
	elif game_params.story_vars.apata_trap_stage == GameParams.ApataTrapStages.DISABLED \
		and ( \
			conversation_manager.conversation_is_finished(game_params.get_player(), "010-2-3_CeilingUp") \
			or conversation_manager.conversation_is_in_progress("010-2-3_CeilingUp")
		):
			conversation_manager.start_area_conversation("010-2-4_ApataDoneMax")

func _on_conversation_finished(player, conversation_name, is_cutscene):
	match conversation_name:
		"010-2-2_CeilingStopped":
			$DeactivationTimer.start()

func _on_DeactivationTimer_timeout():
	deactivate()
	conversation_manager.start_area_conversation("010-2-3_CeilingUp")
