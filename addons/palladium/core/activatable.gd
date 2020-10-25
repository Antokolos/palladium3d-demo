extends Spatial
class_name PLDActivatable

export(DB.ActivatableIds) var activatable_id = DB.ActivatableIds.NONE
export(PLDGameState.ActivatableState) var default_state = PLDGameState.ActivatableState.DEACTIVATED

func _ready():
	if Engine.editor_hint:
		return
	game_state.register_activatable(self)

func get_activatable_id():
	return activatable_id

func get_activatable_state():
	return game_state.get_activatable_state(get_path())

func is_untouched():
	return get_activatable_state() == PLDGameState.ActivatableState.DEFAULT

func is_activated():
	var state = get_activatable_state()
	match state:
		PLDGameState.ActivatableState.ACTIVATED:
			return true
		PLDGameState.ActivatableState.ACTIVATED_FOREVER:
			return true
		_:
			return false

func activate(and_change_state = true):
	if and_change_state and not is_final_destination():
		game_state.set_activatable_state(get_path(), PLDGameState.ActivatableState.ACTIVATED)

func is_deactivated():
	var state = get_activatable_state()
	match state:
		PLDGameState.ActivatableState.DEACTIVATED:
			return true
		PLDGameState.ActivatableState.DEACTIVATED_FOREVER:
			return true
		_:
			return false

func deactivate(and_change_state = true):
	if and_change_state and not is_final_destination():
		game_state.set_activatable_state(get_path(), PLDGameState.ActivatableState.DEACTIVATED)

func is_paused():
	var state = get_activatable_state()
	match state:
		PLDGameState.ActivatableState.PAUSED:
			return true
		PLDGameState.ActivatableState.PAUSED_FOREVER:
			return true
		_:
			return false

func pause(and_change_state = true):
	if and_change_state and not is_final_destination():
		game_state.set_activatable_state(get_path(), PLDGameState.ActivatableState.PAUSED)

func is_final_destination():
	var state = get_activatable_state()
	match state:
		PLDGameState.ActivatableState.DEFAULT, \
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

func activate_forever(and_change_state = true):
	if and_change_state and not is_final_destination():
		game_state.set_activatable_state(get_path(), PLDGameState.ActivatableState.ACTIVATED_FOREVER)

func deactivate_forever(and_change_state = true):
	if and_change_state and not is_final_destination():
		game_state.set_activatable_state(get_path(), PLDGameState.ActivatableState.DEACTIVATED_FOREVER)

func pause_forever(and_change_state = true):
	if and_change_state and not is_final_destination():
		game_state.set_activatable_state(get_path(), PLDGameState.ActivatableState.PAUSED_FOREVER)

func restore_state():
	var state = get_activatable_state()
	restore_from_state(state)

func restore_from_state(state):
	match state:
		PLDGameState.ActivatableState.DEFAULT:
			if default_state == PLDGameState.ActivatableState.DEFAULT:
				push_error("Activatable default state is set to Default")
			else:
				restore_from_state(default_state)
		PLDGameState.ActivatableState.ACTIVATED:
			activate(false)
		PLDGameState.ActivatableState.DEACTIVATED:
			deactivate(false)
		PLDGameState.ActivatableState.PAUSED:
			pause(false)
		PLDGameState.ActivatableState.ACTIVATED_FOREVER:
			activate_forever(false)
		PLDGameState.ActivatableState.DEACTIVATED_FOREVER:
			deactivate_forever(false)
		PLDGameState.ActivatableState.PAUSED_FOREVER:
			pause_forever(false)
		_:
			push_warning("Unknown activatable state: " + str(state))