tool
extends PLDConversationArea

func is_conversation_enabled(name_hint, conversation_idx):
	var erida_trap = game_state.get_activatable(DB.ActivatableIds.ERIDA_TRAP)
	var is_before_eris = (
		erida_trap
		and erida_trap.is_untouched()
		and game_state.get_activatable_state_by_id(DB.ActivatableIds.APATA_TRAP) == PLDGameState.ActivatableState.DEACTIVATED_FOREVER
	)
	match name_hint:
		CHARS.FEMALE_NAME_HINT:
			match conversation_idx:
				0:
					return is_before_eris
				1:
					return not is_before_eris and (game_state.get_activatable_state_by_id(DB.ActivatableIds.ERIDA_TRAP) == PLDGameState.ActivatableState.DEACTIVATED_FOREVER)
		CHARS.BANDIT_NAME_HINT:
			return is_before_eris
