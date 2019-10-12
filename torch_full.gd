extends StaticBody

export var persistent = false

var burning = true
onready var torch_fire = get_node("torch_wall/torch_fire")
onready var torch_light = get_node("torch_wall/torch_light")
onready var raycast = get_node("RayCast")

func _ready():
	torch_fire.enable(burning)
	torch_light.enable(burning)

func use(player_node):
	burning = not burning
	if burning:
		$AudioStreamLighter.play()
	else:
		$AudioStreamBurning.stop()
	torch_fire.enable(burning)
	torch_light.enable(burning)

func add_highlight(player_node):
	return ("E: Потушить факел" if burning else "E: Зажечь факел")

func remove_highlight(player_node):
	pass

func _on_AudioStreamLighter_finished():
	$AudioStreamBurning.play()

func _physics_process(delta):
	if not torch_light.visible:
		return
	var player = get_node(game_params.player_path)
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
	raycast.enabled = true

func _on_VisibilityNotifier_screen_exited():
	raycast.enabled = false
