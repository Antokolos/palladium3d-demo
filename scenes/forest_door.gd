extends PLDUsable

const STATE_OPENED = 1

onready var anim_player = get_parent().get_node("forest_door_armature001/AnimationPlayer")

func _ready():
	restore_state()

func use(player_node, camera_node):
	var barn_lock_path = game_state.get_usable_path(DB.UsableIds.BARN_LOCK)
	if anim_player.is_playing() \
		or game_state.get_multistate_state(get_path()) == STATE_OPENED \
		or game_state.get_multistate_state(barn_lock_path) != BarnLock.STATE_OPENED:
		return
	door_open(true, true)

func add_highlight(player_node):
	var barn_lock_path = game_state.get_usable_path(DB.UsableIds.BARN_LOCK)
	if game_state.get_multistate_state(barn_lock_path) == BarnLock.STATE_OPENED:
		return "E: " + tr("ACTION_OPEN")
	return ""

func door_open(with_sound, update_state):
	get_node("closed_door").disabled = true
	get_node("opened_door").disabled = false
	anim_player.play("ArmatureAction.001", -1, 0.35)
	if with_sound:
		$AudioStreamPlayer.play()
	if update_state:
		game_state.set_multistate_state(get_path(), STATE_OPENED)

func restore_state():
	var state = game_state.get_multistate_state(get_path())
	if state == STATE_OPENED:
		door_open(false, false)
