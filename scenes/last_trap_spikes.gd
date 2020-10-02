extends Spatial

func _ready():
	conversation_manager.connect("conversation_finished", self, "_on_conversation_finished")

func activate():
	get_node("ceiling_armat005/AnimationPlayer").play("trap_final_1.001")
	get_node("ceiling_armat004/AnimationPlayer").play("trap_final_1")
	get_node("AnimationPlayer").play("spikes_on")

func _on_conversation_finished(player, conversation_name, target, initiator):
	match conversation_name:
		"175_Andreas_what_is_that_sound":
			activate()
			conversation_manager.start_area_conversation("175-3_Andreas_spikes")
		"175-1_Spikes_are_close":
			get_node("ceiling_armat005/AnimationPlayer").play("trap_final_1.001")
			get_node("ceiling_armat004/AnimationPlayer").play("trap_final_1")
			get_node("AnimationPlayer").play("spikes_off")
			conversation_manager.start_area_conversation("175-1-1_Spikes_are_back")

func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"spikes_on":
			get_node("ceiling_armat005/AnimationPlayer").stop(false)
			get_node("ceiling_armat004/AnimationPlayer").stop(false)
			conversation_manager.start_area_conversation("175-1_Spikes_are_close")
		"spikes_off":
			get_node("Armature033/AnimationPlayer").play("last_trap_steps")
			get_node("AnimationPlayer").play("steps_up")


func _on_Area_body_entered(body):
	if not body.is_in_group("party"):
		return
	var companion = game_state.get_character(CHARS.FEMALE_NAME_HINT)
	if not companion.equals(body):
		return
	companion.leave_party()
	companion.set_target_node(get_node("Position3D"))
	conversation_manager.start_area_conversation("174-1_Are_you_alright")

func _on_Area_body_exited(body):
	if not body.is_in_group("party"):
		return
	var companion = game_state.get_character(CHARS.FEMALE_NAME_HINT)
	if not companion.equals(body):
		return
	companion.clear_target_node()
	companion.join_party()