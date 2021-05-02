extends PLDUsable
class_name DestructibleWeb

signal web_destroyed(web)

const STATE_DESTROYED = 1

func use(player_node, camera_node):
	if game_state.get_multistate_state(get_path()) == STATE_DESTROYED:
		return
	destroy_web(true, true)

func get_usage_code(player_node):
	return "ACTION_IGNITE"

func destroy_web(with_effects, update_state):
	if with_effects:
		$flames.visible = true
		$DestroyTimer.start()
		MEDIA.play_sound(MEDIA.SoundId.FIRE_LIGHTER)
		$AudioStreamBurning.play()
	else:
		_on_DestroyTimer_timeout()
	if update_state:
		game_state.set_multistate_state(get_path(), STATE_DESTROYED)

func _on_DestroyTimer_timeout():
	emit_signal("web_destroyed", self)
	$AudioStreamBurning.stop()
	$CollisionShape.disabled = true
	$flames.visible = false
	$spider_web_1.visible = false
	$spider_web_2.visible = false

func restore_state():
	var state = game_state.get_multistate_state(get_path())
	if state == STATE_DESTROYED:
		destroy_web(false, false)
