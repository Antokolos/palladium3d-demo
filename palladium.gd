extends PLDLevel

var player_toggle_enable = true

func do_init(is_loaded):
	player.set_sound_walk(CHARS.SoundId.SOUND_WALK_CONCRETE)
	player_female.set_sound_walk(CHARS.SoundId.SOUND_WALK_CONCRETE)
	player_bandit.set_sound_walk(CHARS.SoundId.SOUND_WALK_CONCRETE)
	player_bandit.set_sound_attack(CHARS.SoundId.SOUND_ATTACK_GUNSHOT)
	player_bandit.set_sound_miss(CHARS.SoundId.SOUND_ATTACK_GUNSHOT)
	if has_node("greek_skeleton"):
		var sk = get_node("greek_skeleton")
		sk.set_sound_walk(CHARS.SoundId.SOUND_WALK_SKELETON)
		sk.set_sound_attack(CHARS.SoundId.SOUND_ATTACK_SWOOSH)
		sk.set_sound_miss(CHARS.SoundId.SOUND_ATTACK_SWOOSH)
	if has_node("minotaur"):
		var m = get_node("minotaur")
		m.set_sound_walk(CHARS.SoundId.SOUND_WALK_MINOTAUR)
		m.set_sound_angry(CHARS.SoundId.SOUND_MONSTER_ROAR)
		m.set_sound_pain(CHARS.SoundId.SOUND_MONSTER_ROAR)
		m.set_sound_attack(CHARS.SoundId.SOUND_ATTACK_AXE_ON_STONE)
		m.set_sound_miss(CHARS.SoundId.SOUND_ATTACK_AXE_ON_STONE)
	if not conversation_manager.conversation_is_in_progress("004_TorchesIgnition") and conversation_manager.conversation_is_not_finished("004_TorchesIgnition"):
		get_tree().call_group("torches", "enable", false, false)
	game_state.connect("shader_cache_processed", self, "_on_shader_cache_processed")
	if is_loaded:
		return
	MEDIA.change_music_to(MEDIA.MusicId.EXPLORE)
	var apata_trap = game_state.get_activatable(DB.ActivatableIds.APATA_TRAP)
	if apata_trap \
		and apata_trap.is_untouched() \
		and conversation_manager.meeting_is_finished(CHARS.PLAYER_NAME_HINT, CHARS.BANDIT_NAME_HINT):
		var floor_demo_full = get_node("NavigationMeshInstance/floor_demo_full")
		player_female.teleport(floor_demo_full.get_node("PositionApata"))
		player_bandit.teleport(floor_demo_full.get_node("BanditSavePosition"))
	else:
		player.teleport($PositionPlayer)
		if player_female.is_in_party():
			player_female.teleport($PositionCompanion)
			player_bandit.teleport($PositionOut)
			player_bandit.deactivate()
		elif player_bandit.is_in_party():
			player_bandit.teleport($PositionCompanion)
			player_female.teleport($PositionOut)
			player_female.deactivate()

func _on_shader_cache_processed():
	game_state.get_hud().queue_popup_message("MESSAGE_CONTROLS_FLASHLIGHT", [common_utils.get_input_control("flashlight", false)])

func _unhandled_input(event):
	if not player_toggle_enable:
		return
	if event is InputEventKey:
		match event.scancode:
			KEY_9:
				player.become_player()
			KEY_0:
				player_female.become_player()
