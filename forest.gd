extends PLDLevel

onready var pocket_book = get_node("pocket_book")

func do_init(is_loaded):
	if not game_state.story_vars.is_game_start and not is_loaded:
		player.teleport($PositionPlayer)
		if game_state.is_in_party(CHARS.FEMALE_NAME_HINT):
			player_female.teleport($PositionCompanion)
			player_bandit.teleport($PositionOut)
			player_bandit.deactivate()
		elif game_state.is_in_party(CHARS.BANDIT_NAME_HINT):
			player_bandit.teleport($PositionCompanion)
			player_female.teleport($PositionOut)
			player_female.deactivate()
	if game_state.story_vars.is_game_start:
		game_state.story_vars.is_game_start = false
	if conversation_manager.meeting_is_finished(CHARS.PLAYER_NAME_HINT, CHARS.FEMALE_NAME_HINT):
		remove_pocket_book()
	get_tree().call_group("takables", "connect_signals", self)
	game_state.connect("item_used", self, "on_item_used")
	game_state.connect("shader_cache_processed", self, "_on_shader_cache_processed")
	conversation_manager.connect("conversation_finished", self, "_on_conversation_finished")
	conversation_manager.connect("meeting_started", self, "_on_meeting_started")
	var player_in_grass = $AreaGrass.overlaps_body(player)
	var female_in_grass = $AreaGrass.overlaps_body(player_female)
	var bandit_in_grass = $AreaGrass.overlaps_body(player_bandit)
	player.set_sound_walk(CHARS.SoundId.SOUND_WALK_GRASS if player_in_grass else CHARS.SoundId.SOUND_WALK_SAND)
	MEDIA.change_music_to(MEDIA.MusicId.OUTSIDE)
	player_female.set_sound_walk(CHARS.SoundId.SOUND_WALK_GRASS if female_in_grass else CHARS.SoundId.SOUND_WALK_SAND)
	player_bandit.set_sound_walk(CHARS.SoundId.SOUND_WALK_GRASS if bandit_in_grass else CHARS.SoundId.SOUND_WALK_SAND)
	var boat_area = get_node("BoatArea")
	if boat_area and boat_area.overlaps_body(player) and boat_area.overlaps_body(player_female):
		_on_BoatArea_body_entered(player)

func remove_pocket_book():
	if pocket_book:
		pocket_book.queue_free()
		pocket_book = null

func use_takable(player_node, takable, parent, was_taken):
	var takable_id = takable.takable_id
	match takable_id:
		DB.TakableIds.ENVELOPE:
			game_state.remove(DB.TakableIds.ISLAND_MAP)
			if player_female.is_in_party():
				conversation_manager.start_conversation(player, "001_Oak")

func on_item_used(item_id, target):
	if item_id == DB.TakableIds.BARN_LOCK_KEY and target is BarnLock:
		var was_in_party = player_female.is_in_party()
		if not was_in_party:
			player_female.join_party()
			player_female.teleport(get_node("PositionCompanion"))
		
		if was_in_party:
			conversation_manager.start_conversation(player, "001_Door")
		else:
			var boatFinished = conversation_manager.conversation_is_finished("001_Boat")
			if boatFinished:
				conversation_manager.start_conversation(player, "001_Door3")
			else:
				var meetingXeniaFinished = conversation_manager.meeting_is_finished_exact(CHARS.PLAYER_NAME_HINT, CHARS.FEMALE_NAME_HINT)
				conversation_manager.start_conversation(player, "001_Door2" if meetingXeniaFinished else "003_Door")

func do_final_tween():
	var tween = $FinalCutsceneTween
	tween.interpolate_property(
		$PositionFinalCutscene,
		"translation",
		$PositionFinalCutscene.get_global_transform().origin,
		$PositionFinalCutscene2.get_global_transform().origin,
		22,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN_OUT
	)
	tween.start()

func _on_shader_cache_processed():
	if game_state.is_in_party(CHARS.FEMALE_NAME_HINT):
		if game_state.has_item(DB.TakableIds.ATHENA) \
			or game_state.has_item(DB.TakableIds.PALLADIUM):
			if player_female.get_relationship() > 0:
				conversation_manager.start_area_cutscene(
					"171_Why_are_you_so_sad",
					$PositionFinalCutscene
				)
			else:
				cutscene_manager.borrow_camera(player, $PositionFinalCutscene)
			player.set_target_node($PositionPlayer2)
			player.set_force_physics(true)
			player_female.set_target_node($PositionCompanion2)
			player_female.set_force_physics(true)
			player.leave_party()
			player_female.leave_party()
			do_final_tween()
	elif game_state.is_in_party(CHARS.BANDIT_NAME_HINT):
		if game_state.has_item(DB.TakableIds.GOLDEN_BAR):
			conversation_manager.start_area_cutscene(
				"172_We_made_a_great_team",
				$PositionFinalCutscene
			)
			player.set_target_node($PositionPlayer2)
			player.set_force_physics(true)
			player_bandit.set_target_node($PositionCompanion2)
			player_bandit.set_force_physics(true)
			player.leave_party()
			player_bandit.leave_party()
			do_final_tween()

func _on_meeting_started(player, target, initiator):
	remove_pocket_book()
	player_female.set_target_node(get_node("PositionBoat"))
	player_female.play_cutscene(FemaleModel.FEMALE_CUTSCENE_STAND_UP_STUMP)

func _on_AreaGrass_body_entered(body):
	if body.is_in_group("party"):
		if not $TunnelArea.overlaps_body(body):
			body.set_sound_walk(CHARS.SoundId.SOUND_WALK_GRASS)

func _on_AreaGrass_body_exited(body):
	if body.is_in_group("party") and not game_state.is_loading():
		body.set_sound_walk(CHARS.SoundId.SOUND_WALK_SAND)

func _on_StumpArea_body_exited(body):
	if body.is_in_group("party") and not game_state.is_loading():
		conversation_manager.arrange_meeting(player, player, player_female)

func _on_RockArea_body_exited(body):
	if game_state.has_item(DB.TakableIds.ENVELOPE) or game_state.has_item(DB.TakableIds.BARN_LOCK_KEY):
		_on_StumpArea_body_exited(body)

func _on_BoatArea_body_entered(body):
	if not body is PLDPlayer \
		or game_state.is_loading() \
		or not player_female.is_rest_state():
		return
	var boat_area = get_node("BoatArea")
	if not boat_area or not boat_area.overlaps_body(player) or not boat_area.overlaps_body(player_female):
		return
	var boatFinished = conversation_manager.conversation_is_finished("001_Boat")
	if not boatFinished:
		if conversation_manager.meeting_is_finished(CHARS.FEMALE_NAME_HINT, CHARS.PLAYER_NAME_HINT):
			conversation_manager.start_conversation(player, "001_Boat")

func _on_TunnelArea_body_entered(body):
	if body.is_in_group("party"):
		body.set_sound_walk(CHARS.SoundId.SOUND_WALK_CONCRETE)
		body.set_pathfinding_enabled(false)

func _on_TunnelArea_body_exited(body):
	if body.is_in_group("party") and not game_state.is_loading():
		body.set_sound_walk(CHARS.SoundId.SOUND_WALK_GRASS)
		body.set_pathfinding_enabled(true)

func _on_FinalCutsceneTween_tween_completed(object, key):
	if player_female.get_relationship() == 0:
		conversation_manager.start_area_cutscene(
			"171-1_I_would_not_leave_you",
			$PositionFinalCutscene
		)

func _on_conversation_finished(player, conversation_name, target, initiator, last_result):
	match conversation_name:
		"171-1_I_would_not_leave_you":
			cutscene_manager.borrow_camera(player, $PositionFinalCutscene2)
			game_state.change_scene("res://ending_2.tscn", false, true)
		"171_Why_are_you_so_sad":
			if game_state.has_item(DB.TakableIds.PALLADIUM):
				cutscene_manager.borrow_camera(player, $PositionFinalCutscene2)
				game_state.change_scene("res://ending_1.tscn", false, true)
			else:
				cutscene_manager.borrow_camera(player, $PositionFinalCutscene2)
				game_state.change_scene("res://ending_2.tscn", false, true)
		"172_We_made_a_great_team":
			if game_state.has_item(DB.TakableIds.ATHENA):
				cutscene_manager.borrow_camera(player, $PositionFinalCutscene2)
				game_state.change_scene("res://ending_4.tscn", false, true)
			else:
				cutscene_manager.borrow_camera(player, $PositionFinalCutscene2)
				game_state.change_scene("res://ending_3.tscn", false, true)