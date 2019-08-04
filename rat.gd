extends RigidBody

export var player_path = "../player"
onready var rat = get_node("Rotation_Helper/Model/rat_grey")

const SAFE_RANGE = 3
const WARN_RANGE = 2
const RETREAT_RANGE = 1
const ALIGNMENT_RANGE = 0.2

func _integrate_forces(state):
	var player = get_node(player_path)
	if not player:
		return
	var current_transform = get_global_transform()
	var current_position = current_transform.origin
	var player_position = player.get_global_transform().origin
	var dir = player_position - current_position
	var l = dir.length()
	if l > SAFE_RANGE:
		rat.rest()
	elif l > WARN_RANGE:
		rat.sits_sniff()
	elif l > RETREAT_RANGE:
		rat.run()