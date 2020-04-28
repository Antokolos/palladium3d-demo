extends PalladiumLevel

func do_init(is_loaded):
	if not game_params.story_vars.is_game_start and not is_loaded:
		var player_basis = $PositionPlayer.get_transform().basis
		var player_origin = $PositionPlayer.get_transform().origin
		var companion_basis = $PositionCompanion.get_transform().basis
		var companion_origin = $PositionCompanion.get_transform().origin
		player.set_transform(Transform(player_basis, player_origin))
		player_female.set_transform(Transform(companion_basis, companion_origin))
	get_tree().call_group("takables", "connect_signals", self)
	game_params.connect("shader_cache_processed", self, "_on_shader_cache_processed")
	game_params.connect("item_used", self, "on_item_used")
	conversation_manager.connect("meeting_started", self, "_on_meeting_started")
	var player_in_grass = $AreaGrass.overlaps_body(player)
	var female_in_grass = $AreaGrass.overlaps_body(player_female)
	player.set_sound_walk(player.SOUND_WALK_GRASS if player_in_grass else player.SOUND_WALK_SAND)
	game_params.change_music_to("underwater.ogg")
	player_female.set_sound_walk(player_female.SOUND_WALK_GRASS if female_in_grass else player_female.SOUND_WALK_SAND)

func use_takable(player_node, takable, parent, was_taken):
	var takable_id = takable.takable_id
	match takable_id:
		Takable.TakableIds.ENVELOPE:
			if player_female.is_in_party():
				conversation_manager.start_conversation(player, "001_Oak")

func on_item_used(player_node, target, item_nam):
	if item_nam == "barn_lock_key" and target is BarnLock:
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
				var meetingXeniaFinished = conversation_manager.meeting_is_finished_exact(game_params.PLAYER_NAME_HINT, game_params.FEMALE_NAME_HINT)
				conversation_manager.start_conversation(player, "001_Door2" if meetingXeniaFinished else "003_Door")

func _on_meeting_started(player, target, initiator):
	player_female.set_target_node(get_node("PositionBoat"))
	player_female.play_cutscene(PalladiumCharacter.FEMALE_CUTSCENE_STAND_UP_STUMP)

func _on_AreaGrass_body_entered(body):
	if body == player:
		player.set_sound_walk(player.SOUND_WALK_GRASS)
	if body == player_female:
		player_female.set_sound_walk(player_female.SOUND_WALK_GRASS)

func _on_AreaGrass_body_exited(body):
	if body == player:
		player.set_sound_walk(player.SOUND_WALK_SAND)
	if body == player_female:
		player_female.set_sound_walk(player_female.SOUND_WALK_SAND)

func _on_StumpArea_body_exited(body):
	conversation_manager.arrange_meeting(player, player, player_female)

func _on_RockArea_body_exited(body):
	if game_params.has_item("envelope") or game_params.has_item("barn_lock_key"):
		_on_StumpArea_body_exited(body)

func _on_BoatArea_body_entered(body):
	if player_female.companion_state != PalladiumPlayer.COMPANION_STATE.REST:
		return
	var boatFinished = conversation_manager.conversation_is_finished("001_Boat")
	if not boatFinished:
		if conversation_manager.meeting_is_finished(game_params.FEMALE_NAME_HINT, game_params.PLAYER_NAME_HINT):
			conversation_manager.start_conversation(player, "001_Boat")

func _on_TunnelArea_body_entered(body):
	if body.is_in_group("party"):
		body.set_pathfinding_enabled(false)

func _on_TunnelArea_body_exited(body):
	if body.is_in_group("party"):
		body.set_pathfinding_enabled(true)
