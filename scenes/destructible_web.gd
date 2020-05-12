extends StaticBody

signal web_destroyed(web)

const STATE_DESTROYED = 1

func _ready():
	restore_state()

func use(player_node):
	if game_params.get_multistate_state(get_path()) == STATE_DESTROYED:
		return
	destroy_web(true, true)

func destroy_web(with_effects, update_state):
	if with_effects:
		$flames.visible = true
		$DestroyTimer.start()
		$AudioStreamLighter.play()
		$AudioStreamBurning.play()
	else:
		_on_DestroyTimer_timeout()
	if update_state:
		game_params.set_multistate_state(get_path(), STATE_DESTROYED)

func _on_DestroyTimer_timeout():
	emit_signal("web_destroyed", self)
	$AudioStreamBurning.stop()
	$CollisionShape.disabled = true
	$flames.visible = false
	$spider_web_1.visible = false
	$spider_web_2.visible = false

func add_highlight(player_node):
	return "E: " + tr("ACTION_IGNITE")

func remove_highlight(player_node):
	pass

func restore_state():
	var state = game_params.get_multistate_state(get_path())
	if state == STATE_DESTROYED:
		destroy_web(false, false)
