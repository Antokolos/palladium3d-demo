extends StaticBody
class_name LightSource

const DISTANCE_TO_CAMERA_MAX = 36

enum LightIds {
	NONE = 0
}
export(LightIds) var light_id = LightIds.NONE
export var initially_active = true
export var persistent = false

onready var torch_fire = get_node("torch_wall/torch_fire")
onready var torch_light = get_node("torch_wall/torch_light")
onready var raycast = get_node("RayCast")
var screen_entered = false

func _ready():
	restore_state()

func is_active():
	var ls = game_params.get_light_state(get_path())
	return (ls == game_params.LightState.DEFAULT and initially_active) or (ls == game_params.LightState.ON)

func enable(active, update):
	torch_fire.enable(active)
	torch_light.enable(active)
	if update:
		game_params.set_light_state(get_path(), active)

func use(player_node):
	var active = not is_active()
	if active:
		$AudioStreamLighter.play()
	else:
		$AudioStreamBurning.stop()
	enable(active, true)

func add_highlight(player_node):
	return ("E: Потушить факел" if is_active() else "E: Зажечь факел")

func remove_highlight(player_node):
	pass

func restore_state():
	var active = is_active()
	enable(active, false)

func _on_AudioStreamLighter_finished():
	$AudioStreamBurning.play()

func _physics_process(delta):
	if not screen_entered or not torch_light.visible or persistent:
		raycast.enabled = false
		return
	var player = game_params.get_player()
	if player:
		var camera = player.get_cam()
		var origin = camera.get_global_transform().origin
		var ray_vec = raycast.to_local(origin)
		var rl = ray_vec.length()
		var is_far_away = rl > DISTANCE_TO_CAMERA_MAX
		var is_outside_camera = rl > camera.far
		self.visible = persistent or ray_vec.x < 0
		raycast.enabled = screen_entered and not is_outside_camera
		if raycast.enabled:
			raycast.cast_to = ray_vec
		if torch_fire.is_simple_mode():
			if raycast.enabled and not raycast.is_colliding() and not is_far_away:
				torch_fire.set_simple_mode(false)
				torch_light.enable_shadow_if_needed(true)
		else:
			if not raycast.enabled or raycast.is_colliding() or is_far_away:
				torch_fire.set_simple_mode(true)
				torch_light.enable_shadow_if_needed(false)

func _on_VisibilityNotifier_screen_entered():
	if persistent:
		return
	screen_entered = true

func _on_VisibilityNotifier_screen_exited():
	if persistent:
		return
	screen_entered = false
