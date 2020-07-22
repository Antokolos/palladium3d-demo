extends PLDLevel

func do_init(is_loaded):
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	game_state.change_music_to(game_state.MusicId.LOADING)
