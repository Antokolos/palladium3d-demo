extends StaticBody

var burning = true
onready var torch_fire = get_node("torch_wall/torch_fire")
onready var torch_light = get_node("torch_wall/torch_light")

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
