tool
extends PLDConversationArea

func is_conversation_enabled(name_hint, conversation_idx):
	return game_state.get_activatable_state_by_id(DB.ActivatableIds.ERIDA_TRAP) == PLDGameState.ActivatableState.DEACTIVATED_FOREVER