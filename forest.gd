extends PLDLevel

onready var pocket_book = get_node("pocket_book")

func do_init(is_loaded):
	if not game_state.story_vars.is_game_start and not is_loaded:
		var player_basis = $PositionPlayer.get_transform().basis
		var player_origin = $PositionPlayer.get_transform().origin
		var companion_basis = $PositionCompanion.get_transform().basis
		var companion_origin = $PositionCompanion.get_transform().origin
		player.set_transform(Transform(player_basis, player_origin))
		player_female.set_transform(Transform(companion_basis, companion_origin))
	if game_state.story_vars.is_game_start:
		game_state.story_vars.is_game_start = false
	if conversation_manager.meeting_is_finished(DB.PLAYER_NAME_HINT, DB.FEMALE_NAME_HINT):
		remove_pocket_book()
	get_tree().call_group("takables", "connect_signals", self)
	game_state.connect("item_used", self, "on_item_used")
	conversation_manager.connect("meeting_started", self, "_on_meeting_started")
	var player_in_grass = $AreaGrass.overlaps_body(player)
	var female_in_grass = $AreaGrass.overlaps_body(player_female)
	player.set_sound_walk(PLDCharacterNodes.SoundId.SOUND_WALK_GRASS if player_in_grass else PLDCharacterNodes.SoundId.SOUND_WALK_SAND)
	game_state.change_music_to(game_state.MusicId.OUTSIDE)
	player_female.set_sound_walk(PLDCharacterNodes.SoundId.SOUND_WALK_GRASS if female_in_grass else PLDCharacterNodes.SoundId.SOUND_WALK_SAND)
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
				var meetingXeniaFinished = conversation_manager.meeting_is_finished_exact(DB.PLAYER_NAME_HINT, DB.FEMALE_NAME_HINT)
				conversation_manager.start_conversation(player, "001_Door2" if meetingXeniaFinished else "003_Door")

func _on_meeting_started(player, target, initiator):
	remove_pocket_book()
	player_female.set_target_node(get_node("PositionBoat"))
	player_female.play_cutscene(FemaleModel.FEMALE_CUTSCENE_STAND_UP_STUMP)

func _on_AreaGrass_body_entered(body):
	if body.is_in_group("party"):
		if not $TunnelArea.overlaps_body(body):
			body.set_sound_walk(PLDCharacterNodes.SoundId.SOUND_WALK_GRASS)

func _on_AreaGrass_body_exited(body):
	if body.is_in_group("party") and not game_state.is_loading():
		body.set_sound_walk(PLDCharacterNodes.SoundId.SOUND_WALK_SAND)

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
		if conversation_manager.meeting_is_finished(DB.FEMALE_NAME_HINT, DB.PLAYER_NAME_HINT):
			conversation_manager.start_conversation(player, "001_Boat")

func _on_TunnelArea_body_entered(body):
	if body.is_in_group("party"):
		body.set_sound_walk(PLDCharacterNodes.SoundId.SOUND_WALK_CONCRETE)
		body.set_pathfinding_enabled(false)

func _on_TunnelArea_body_exited(body):
	if body.is_in_group("party") and not game_state.is_loading():
		body.set_sound_walk(PLDCharacterNodes.SoundId.SOUND_WALK_GRASS)
		body.set_pathfinding_enabled(true)
