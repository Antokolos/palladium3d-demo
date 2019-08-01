extends StaticBody

var burning = true
onready var torch_fire = get_node("torch_wall/torch_fire")
onready var torch_light = get_node("torch_wall/torch_light")

func _ready():
	torch_fire.enable(burning)
	torch_light.enable(burning)

func use(player_node):
	burning = not burning
	torch_fire.enable(burning)
	torch_light.enable(burning)

func add_highlight():
	return ("E: Потушить факел" if burning else "E: Зажечь факел")

func remove_highlight():
	pass
