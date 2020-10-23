extends PLDActivatable

const SPIKES_SPEED = 0.2

func _ready():
	conversation_manager.connect("conversation_finished", self, "_on_conversation_finished")
	get_tree().call_group("use_targets", "connect_signals", self)

func use_usable(player_node, usable):
	var usable_id = usable.usable_id
	match usable_id:
		DB.UsableIds.LAST_TRAP_POSTAMENT:
			pass

func use_use_target(player_node, use_target, item, result):
	var use_target_id = use_target.use_target_id
	match use_target_id:
		DB.UseTargetIds.LAST_TRAP_POSTAMENT:
			get_node("ceiling_armat005/AnimationPlayer").play_backwards("trap_final_1.001")
			get_node("ceiling_armat004/AnimationPlayer").play_backwards("trap_final_1")
			deactivate()

func activate():
	.activate()
	get_node("ceiling_armat005/AnimationPlayer").play("trap_final_1.001", -1, SPIKES_SPEED)
	get_node("ceiling_armat004/AnimationPlayer").play("trap_final_1", -1, SPIKES_SPEED)
	get_node("AnimationPlayer").play("spikes_on", -1, SPIKES_SPEED)

func deactivate():
	.deactivate()
	get_node("AnimationPlayer").play("spikes_off")

func _on_conversation_finished(player, conversation_name, target, initiator, last_result):
	match conversation_name:
		"175_Andreas_what_is_that_sound":
			activate()
		"175-3_Andreas_spikes":
			get_node("ceiling_armat005/AnimationPlayer").play("trap_final_1.001", -1, SPIKES_SPEED)
			get_node("ceiling_armat004/AnimationPlayer").play("trap_final_1", -1, SPIKES_SPEED)
			get_node("AnimationPlayer").play("spikes_on_2", -1, SPIKES_SPEED)
		"175-1_Spikes_are_close":
			get_node("ceiling_armat005/AnimationPlayer").play("trap_final_1.001", -1, SPIKES_SPEED)
			get_node("ceiling_armat004/AnimationPlayer").play("trap_final_1", -1, SPIKES_SPEED)
			get_node("AnimationPlayer").play("spikes_on_3", -1, SPIKES_SPEED)

func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"spikes_on":
			get_node("ceiling_armat005/AnimationPlayer").stop(false)
			get_node("ceiling_armat004/AnimationPlayer").stop(false)
			conversation_manager.start_area_conversation("175-3_Andreas_spikes")
		"spikes_on_2":
			get_node("ceiling_armat005/AnimationPlayer").stop(false)
			get_node("ceiling_armat004/AnimationPlayer").stop(false)
			conversation_manager.start_area_conversation("175-1_Spikes_are_close")
		"spikes_on_3":
			get_node("AnimationPlayer").play("spikes_off", -1, SPIKES_SPEED)
			conversation_manager.start_area_conversation("175-1-1_Spikes_are_back")
		"spikes_off":
			get_node("Armature033/AnimationPlayer").play("last_trap_steps")
			get_node("AnimationPlayer").play("steps_up")
		"steps_up":
			var player = game_state.get_player()
			var companion = game_state.get_character(CHARS.FEMALE_NAME_HINT)
			companion.set_force_physics(false)
			player.set_force_physics(false)
			var last_trap_postament = game_state.get_usable(DB.UsableIds.LAST_TRAP_POSTAMENT)
			if conversation_manager.conversation_is_not_finished("175-1_Spikes_are_close"):
				companion.set_relationship(companion.get_relationship() + 2)
				last_trap_postament.return_palladium(true)
				conversation_manager.start_area_conversation("175-4_Andreas_thanks")
			elif conversation_manager.conversation_is_not_finished("175-1-1_Spikes_are_back"):
				companion.set_relationship(companion.get_relationship() + 1)
				last_trap_postament.return_palladium(false)
				conversation_manager.start_area_conversation("175-2_You_gave_away")
			else:
				companion.set_relationship(0)
				last_trap_postament.return_palladium(false)
				conversation_manager.start_area_conversation("192_Xenia_are_you_alright")

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