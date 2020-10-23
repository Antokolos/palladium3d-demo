extends Spatial
class_name PLDActivatable

export(DB.ActivatableIds) var activatable_id = DB.ActivatableIds.NONE

func _ready():
	if Engine.editor_hint:
		return
	game_state.register_activatable(self)
	restore_state()

func get_activatable_id():
	return activatable_id

func activate():
	if not is_final_destination():
		game_state.set_activatable_state(get_path(), PLDGameState.ActivatableState.ACTIVATED)

func deactivate():
	if not is_final_destination():
		game_state.set_activatable_state(get_path(), PLDGameState.ActivatableState.DEACTIVATED)

func pause():
	if not is_final_destination():
		game_state.set_activatable_state(get_path(), PLDGameState.ActivatableState.PAUSED)

func is_final_destination():
	var state = game_state.get_activatable_state(get_path())
	match state:
		PLDGameState.ActivatableState.ACTIVATED, \
		PLDGameState.ActivatableState.DEACTIVATED, \
		PLDGameState.ActivatableState.PAUSED:
			return false
		PLDGameState.ActivatableState.ACTIVATED_FOREVER, \
		PLDGameState.ActivatableState.DEACTIVATED_FOREVER, \
		PLDGameState.ActivatableState.PAUSED_FOREVER:
			return true
		_:
			push_warning("Unknown activatable state: " + str(state))
			return false

func activate_forever():
	if not is_final_destination():
		game_state.set_activatable_state(get_path(), PLDGameState.ActivatableState.ACTIVATED_FOREVER)

func deactivate_forever():
	if not is_final_destination():
		game_state.set_activatable_state(get_path(), PLDGameState.ActivatableState.DEACTIVATED_FOREVER)

func pause_forever():
	if not is_final_destination():
		game_state.set_activatable_state(get_path(), PLDGameState.ActivatableState.PAUSED_FOREVER)

func restore_state():
	var state = game_state.get_activatable_state(get_path())
	match state:
		PLDGameState.ActivatableState.DEFAULT:
			pass
		PLDGameState.ActivatableState.ACTIVATED:
			activate()
		PLDGameState.ActivatableState.DEACTIVATED:
			deactivate()
		PLDGameState.ActivatableState.PAUSED:
			pause()
		PLDGameState.ActivatableState.ACTIVATED_FOREVER:
			activate_forever()
		PLDGameState.ActivatableState.DEACTIVATED_FOREVER:
			deactivate_forever()
		PLDGameState.ActivatableState.PAUSED_FOREVER:
			pause_forever()
		_:
			push_warning("Unknown activatable state: " + str(state))