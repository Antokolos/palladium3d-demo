extends PLDUsable

const STATE_OPENED = 1

onready var anim_player = get_parent().get_node("forest_door_armature001/AnimationPlayer")

func use(player_node, camera_node):
	var barn_lock_path = game_state.get_usable_path(DB.UsableIds.BARN_LOCK)
	if anim_player.is_playing() \
		or game_state.get_multistate_state(get_path()) == STATE_OPENED \
		or game_state.get_multistate_state(barn_lock_path) != BarnLock.STATE_OPENED:
		return
	if game_state.has_item(DB.TakableIds.ISLAND_MAP_2):
		game_state.remove(DB.TakableIds.ISLAND_MAP_2)
	door_open(true, true)

func add_highlight(player_node):
	var barn_lock_path = game_state.get_usable_path(DB.UsableIds.BARN_LOCK)
	if game_state.get_multistate_state(barn_lock_path) == BarnLock.STATE_OPENED:
		return common_utils.get_action_input_control() + tr("ACTION_OPEN")
	return ""

func door_open(with_sound, update_state, immediately = false):
	get_node("closed_door").disabled = true
	get_node("opened_door").disabled = false
	var sp = PLDGameState.SPEED_SCALE_INFINITY if immediately else 0.35
	anim_player.play("ArmatureAction.001", -1, sp)
	if with_sound:
		$AudioStreamPlayer.play()
	if update_state:
		game_state.set_multistate_state(get_path(), STATE_OPENED)

func restore_state():
	var state = game_state.get_multistate_state(get_path())
	if state == STATE_OPENED:
		door_open(false, false, true)
