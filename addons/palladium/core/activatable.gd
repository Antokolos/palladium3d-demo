extends Spatial
class_name PLDActivatable

signal state_changed(activatable, previous_state, new_state)

export(PLDDB.ActivatableIds) var activatable_id = PLDDB.ActivatableIds.NONE
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
		PLDGameState.ActivatableState.DEFAULT:
			match default_state:
				PLDGameState.ActivatableState.ACTIVATED:
					return true
				PLDGameState.ActivatableState.ACTIVATED_FOREVER:
					return true
				_:
					return false 
		_:
			return false

func change_state(new_state):
	var path = get_path()
	var previous_state = game_state.get_activatable_state(path)
	game_state.set_activatable_state(get_path(), new_state)
	emit_signal("state_changed", self, previous_state, new_state)

func activate(and_change_state = true, is_restoring = false):
	if and_change_state and not is_final_destination():
		change_state(PLDGameState.ActivatableState.ACTIVATED)

func is_deactivated():
	var state = get_activatable_state()
	match state:
		PLDGameState.ActivatableState.DEACTIVATED:
			return true
		PLDGameState.ActivatableState.DEACTIVATED_FOREVER:
			return true
		PLDGameState.ActivatableState.DEFAULT:
			match default_state:
				PLDGameState.ActivatableState.DEACTIVATED:
					return true
				PLDGameState.ActivatableState.DEACTIVATED_FOREVER:
					return true
				_:
					return false 
		_:
			return false

func deactivate(and_change_state = true, is_restoring = false):
	if and_change_state and not is_final_destination():
		change_state(PLDGameState.ActivatableState.DEACTIVATED)

func is_paused():
	var state = get_activatable_state()
	match state:
		PLDGameState.ActivatableState.PAUSED:
			return true
		PLDGameState.ActivatableState.PAUSED_FOREVER:
			return true
		PLDGameState.ActivatableState.DEFAULT:
			match default_state:
				PLDGameState.ActivatableState.PAUSED:
					return true
				PLDGameState.ActivatableState.PAUSED_FOREVER:
					return true
				_:
					return false 
		_:
			return false

func pause(and_change_state = true, is_restoring = false):
	if and_change_state and not is_final_destination():
		change_state(PLDGameState.ActivatableState.PAUSED)

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

func activate_forever(and_change_state = true, is_restoring = false):
	if and_change_state and not is_final_destination():
		change_state(PLDGameState.ActivatableState.ACTIVATED_FOREVER)

func deactivate_forever(and_change_state = true, is_restoring = false):
	if and_change_state and not is_final_destination():
		change_state(PLDGameState.ActivatableState.DEACTIVATED_FOREVER)

func pause_forever(and_change_state = true, is_restoring = false):
	if and_change_state and not is_final_destination():
		change_state(PLDGameState.ActivatableState.PAUSED_FOREVER)

func restore_state():
	var state = get_activatable_state()
	restore_from_state(state, true)

func restore_from_state(state, is_restoring = false):
	match state:
		PLDGameState.ActivatableState.DEFAULT:
			if default_state == PLDGameState.ActivatableState.DEFAULT:
				push_error("Activatable default state is set to Default")
			else:
				restore_from_state(default_state, is_restoring)
		PLDGameState.ActivatableState.ACTIVATED:
			activate(false, is_restoring)
		PLDGameState.ActivatableState.DEACTIVATED:
			deactivate(false, is_restoring)
		PLDGameState.ActivatableState.PAUSED:
			pause(false, is_restoring)
		PLDGameState.ActivatableState.ACTIVATED_FOREVER:
			activate_forever(false, is_restoring)
		PLDGameState.ActivatableState.DEACTIVATED_FOREVER:
			deactivate_forever(false, is_restoring)
		PLDGameState.ActivatableState.PAUSED_FOREVER:
			pause_forever(false, is_restoring)
		_:
			push_warning("Unknown activatable state: " + str(state))