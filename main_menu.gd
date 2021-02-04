extends PLDLevel

func do_init(is_loaded):
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	MEDIA.change_music_to(MEDIA.MusicId.LOADING)
	PREFS.set_achievement("MAIN_MENU")
	PREFS.resend_achievements()
