extends Spatial

var origin

func _ready():
	origin = get_global_transform().origin
	$AnimationTree.active = true

func use(player_node):
	var state = $AnimationTree.get("parameters/Transition/current")
	$AnimationTree.set("parameters/Transition/current", state + 1 if state < 3 else 1)
	get_global_transform().origin = origin

func add_highlight(player_node):
	return "E: Повернуть"

func remove_highlight(player_node):
	pass