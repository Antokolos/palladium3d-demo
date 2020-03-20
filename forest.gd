extends Spatial
onready var player = get_node("player")
onready var player_female = get_node("player_female")

func _ready():
	var is_loaded = game_params.finish_load()
	if not game_params.story_vars.is_game_start and not is_loaded:
		var player_basis = $PositionPlayer.get_transform().basis
		var player_origin = $PositionPlayer.get_transform().origin
		var companion_basis = $PositionCompanion.get_transform().basis
		var companion_origin = $PositionCompanion.get_transform().origin
		player.set_transform(Transform(player_basis, player_origin))
		player_female.set_transform(Transform(companion_basis, companion_origin))
	game_params.story_vars.is_game_start = false
	game_params.register_player(player)
	game_params.register_player(player_female)
	player_female.set_target_node(get_node("PositionBoat"))
	get_tree().call_group("takables", "connect_signals", self)
	game_params.connect("item_used", self, "on_item_used")
	var player_in_grass = $AreaGrass.overlaps_body(player)
	var female_in_grass = $AreaGrass.overlaps_body(player_female)
	player.set_sound_walk(player.SOUND_WALK_GRASS if player_in_grass else player.SOUND_WALK_SAND)
	game_params.change_music_to("underwater.ogg")
	player_female.set_sound_walk(player_female.SOUND_WALK_GRASS if female_in_grass else player_female.SOUND_WALK_SAND)
	if not is_loaded:
		game_params.autosave_create()

func use_takable(player_node, takable, parent, was_taken):
	var takable_id = takable.takable_id
	match takable_id:
		Takable.TakableIds.ENVELOPE:
			if player_female.is_in_party():
				conversation_manager.start_conversation(player, player_female, "001_Oak")

func on_item_used(player_node, target, item_nam):
	if item_nam == "barn_lock_key" and target is BarnLock:
		var was_in_party = player_female.is_in_party()
		if not was_in_party:
			player_female.join_party()
			player_female.set_target_node(get_node("PositionCompanion"))
			player_female.teleport()
		
		if was_in_party:
			conversation_manager.start_conversation(player, player_female, "001_Door")
		else:
			var boatFinished = conversation_manager.conversation_is_finished(player, "001_Boat")
			if boatFinished:
				conversation_manager.start_conversation(player, player_female, "001_Door3")
			else:
				var meetingXeniaFinished = conversation_manager.conversation_is_finished(player, "001_MeetingXenia")
				conversation_manager.start_conversation(player, player_female, "001_Door2" if meetingXeniaFinished else "003_Door")

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
	var meetingXeniaFinished = conversation_manager.conversation_is_finished(player, "001_MeetingXenia")
	if meetingXeniaFinished:
		return
	if conversation_manager.conversation_is_in_progress("001_MeetingXenia"):
		return
	var meetingAndreasNotFinished = conversation_manager.conversation_is_not_finished(player, "002_MeetingAndreas")
	if meetingAndreasNotFinished and not player_female.is_in_party():
		player_female.join_party()
		conversation_manager.start_conversation(player, player_female, "002_MeetingAndreas")

func _on_RockArea_body_exited(body):
	if game_params.has_item("envelope") or game_params.has_item("barn_lock_key"):
		_on_StumpArea_body_exited(body)

func _on_BoatArea_body_entered(body):
	if player_female.companion_state != PalladiumPlayer.COMPANION_STATE.REST:
		return
	var boatFinished = conversation_manager.conversation_is_finished(player, "001_Boat")
	if not boatFinished:
		var meetingXeniaFinished = conversation_manager.conversation_is_finished(player, "001_MeetingXenia")
		var meetingAndreasFinished = conversation_manager.conversation_is_finished(player, "002_MeetingAndreas")
		if meetingXeniaFinished or meetingAndreasFinished:
			conversation_manager.start_conversation(player, player_female, "001_Boat")