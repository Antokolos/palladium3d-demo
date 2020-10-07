extends PLDLevel

var player_toggle_enable = true

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
	MEDIA.stop_music()
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
		m.set_sound_attack(CHARS.SoundId.SOUND_ATTACK_AXE_ON_STONE)
		m.set_sound_miss(CHARS.SoundId.SOUND_ATTACK_AXE_ON_STONE)
	if not conversation_manager.conversation_is_in_progress("004_TorchesIgnition") and conversation_manager.conversation_is_not_finished("004_TorchesIgnition"):
		get_tree().call_group("torches", "enable", false, false)
	game_state.connect("shader_cache_processed", self, "_on_shader_cache_processed")

func _on_shader_cache_processed():
	game_state.get_hud().queue_popup_message("MESSAGE_CONTROLS_FLASHLIGHT", ["F"])

func _unhandled_input(event):
	if not player_toggle_enable:
		return
	if event is InputEventKey:
		match event.scancode:
			KEY_9:
				player.become_player()
			KEY_0:
				player_female.become_player()
