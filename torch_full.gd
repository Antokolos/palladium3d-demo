extends StaticBody
class_name LightSource

enum LightIds {
	NONE = 0
}
export(LightIds) var light_id = LightIds.NONE
export var initially_active = true
export var persistent = false

onready var torch_fire = get_node("torch_wall/torch_fire")
onready var torch_light = get_node("torch_wall/torch_light")
onready var raycast = get_node("RayCast")

func _ready():
	restore_state()

func is_active():
	var ls = game_params.get_light_state(get_path())
	return (ls == game_params.LightState.DEFAULT and initially_active) or (ls == game_params.LightState.ON)

func use(player_node):
	var active = not is_active()
	if active:
		$AudioStreamLighter.play()
	else:
		$AudioStreamBurning.stop()
	torch_fire.enable(active)
	torch_light.enable(active)
	game_params.set_light_state(get_path(), active)

func add_highlight(player_node):
	return ("E: Потушить факел" if is_active() else "E: Зажечь факел")

func remove_highlight(player_node):
	pass

func restore_state():
	var active = is_active()
	torch_fire.enable(active)
	torch_light.enable(active)

func _on_AudioStreamLighter_finished():
	$AudioStreamBurning.play()

func _physics_process(delta):
	if not torch_light.visible or persistent:
		return
	var player = game_params.get_player()
	if player:
		raycast.cast_to = raycast.to_local(player.get_global_transform().origin)
		self.visible = persistent or raycast.cast_to.x < 0
		if torch_fire.visible:
			if not raycast.enabled or raycast.is_colliding():
				torch_fire.enable(false)
		else:
			if raycast.enabled and not raycast.is_colliding():
				torch_fire.enable(true)

func _on_VisibilityNotifier_screen_entered():
	if persistent:
		return
	raycast.enabled = true

func _on_VisibilityNotifier_screen_exited():
	if persistent:
		return
	raycast.enabled = false
