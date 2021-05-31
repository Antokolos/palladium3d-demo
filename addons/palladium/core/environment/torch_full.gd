extends PLDUsable
class_name PLDLightSource

signal state_changed(light_source, active, updated)

const DISTANCE_TO_CAMERA_MAX = 36

export(DB.LightIds) var light_id = DB.LightIds.NONE
export var initially_active = true
export var persistent = false
export var show_if_on_screen = false

onready var sound_burning = $AudioStreamBurning
onready var torch_fire = get_node("torch_wall/torch_fire")
onready var torch_light = get_node("torch_wall/torch_light")
onready var raycast = get_node("RayCast")
var screen_entered = false

func is_active():
	var ls = game_state.get_light_state(get_path())
	return (ls == game_state.LightState.DEFAULT and initially_active) or (ls == game_state.LightState.ON)

func enable(active, update):
	if torch_fire:
		torch_fire.enable(active)
	if torch_light:
		torch_light.enable(active)
	if update:
		game_state.set_light_state(get_path(), active)
	emit_signal("state_changed", self, active, update)

func use(player_node, camera_node):
	var active = not is_active()
	if active:
		MEDIA.play_sound(MEDIA.SoundId.FIRE_LIGHTER)
		sound_burning.play()
	else:
		MEDIA.play_sound(MEDIA.SoundId.FIRE_EXTINGUISH)
		sound_burning.stop()
	enable(active, true)

func get_usage_code(player_node):
	return "ACTION_EXTINGUISH" if is_active() else "ACTION_IGNITE"

func connect_signals(target):
	connect("state_changed", target, "_on_torch_state_changed")

func decrease_light():
	torch_fire.decrease_flame()
	torch_light.decrease_light()

func restore_light():
	torch_fire.restore_flame()
	torch_light.restore_light()

func restore_state():
	var active = is_active()
	enable(active, false)

func _physics_process(delta):
	if not game_state.is_level_ready():
		return
	if not torch_light.visible or persistent:
		raycast.enabled = false
		return
	var player = game_state.get_player()
	if player:
		var camera = player.get_cam()
		var origin = camera.get_global_transform().origin
		var ray_vec = raycast.to_local(origin)
		var rl = ray_vec.length()
		var is_far_away = rl > DISTANCE_TO_CAMERA_MAX
		var is_outside_camera = rl > camera.far
		raycast.enabled = not is_outside_camera
		if raycast.enabled:
			raycast.cast_to = ray_vec
		self.visible = (
			persistent
				or (show_if_on_screen and screen_entered)
				or (raycast.enabled and not raycast.is_colliding())
		)
		if torch_fire.is_simple_mode():
			if raycast.enabled and not raycast.is_colliding() and not is_far_away:
				torch_fire.set_simple_mode(false)
				torch_light.enable_shadow_if_needed(true)
				if not sound_burning.is_playing():
					sound_burning.play()
		else:
			if not raycast.enabled or raycast.is_colliding() or is_far_away:
				torch_fire.set_simple_mode(true)
				torch_light.enable_shadow_if_needed(false)
				if sound_burning.is_playing():
					sound_burning.stop()

func _on_VisibilityNotifier_screen_entered():
	if persistent:
		return
	screen_entered = true

func _on_VisibilityNotifier_screen_exited():
	if persistent:
		return
	screen_entered = false

func _on_torch_full_tree_entered():
	restore_state()
