extends PLDLevel

func do_init(is_loaded):
	MEDIA.change_music_to(MEDIA.MusicId.LOADING)
	PREFS.set_achievement("MAIN_MENU")
	PREFS.resend_achievements()
	game_state.reset_variables()
	story_node.reset_all() # If we have gone here via game_state.change_scene() we should reset stories state
