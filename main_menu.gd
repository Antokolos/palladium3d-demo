extends PLDLevel

func do_init(is_loaded):
	MEDIA.change_music_to(MEDIA.MusicId.LOADING)
	PREFS.set_achievement("MAIN_MENU")
	PREFS.resend_achievements()
