extends PLDUseTarget
class_name BarnLock

const STATE_OPENED = 1

func _ready():
	restore_state()

func use_action(player_node, item):
	game_params.set_multistate_state(get_path(), STATE_OPENED)
	$AudioStreamPlayer.play()
	visible = false

func get_use_action_text():
	return tr("ACTION_OPEN")

func restore_state():
	var state = game_params.get_multistate_state(get_path())
	if state == STATE_OPENED:
		visible = false
