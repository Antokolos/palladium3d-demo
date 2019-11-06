extends RigidBody

export var floor_path = "../NavigationMeshInstance/floor_demo_full/floor_demo_floor_2/StaticBodyFloor"
onready var exclusions = [get_node(floor_path), self]
onready var rat = get_node("Rotation_Helper/Model/rat_grey")

const SAFE_RANGE = 6
const SNIFF_RANGE = 5
const WARN_RANGE = 3
const RETREAT_RANGE = 1
const ALIGNMENT_RANGE = 0.2

var zero_dir = Vector3(0, 0, 0)
var x_dir = Vector3(4, 0, 0)
var retreating = false

func can_move_without_collision(motion):
	# This condition WAS CORRECTED after switching to 3.1, see here:
	# https://github.com/godotengine/godot/issues/21212
	return motion[0] == 1.0 and motion[1] == 1.0

func _integrate_forces(state):
	var player = game_params.get_player()
	if not player:
		return
	var current_transform = get_global_transform()
	var current_position = current_transform.origin
	var player_position = player.get_global_transform().origin
	var dir = player_position - current_position
	var l = dir.length()
	state.set_linear_velocity(zero_dir)
	if not retreating and l > SAFE_RANGE:
		rat.rest()
	elif not retreating and l > SNIFF_RANGE:
		rat.rest_sniff()
	elif not retreating and l > WARN_RANGE:
		rat.sits_sniff()
	elif retreating or l > RETREAT_RANGE:
		if not retreating:
			$AudioStreamPlayer3D.play()
		retreating = true
		rat.run()
		var run_dir = current_transform.basis.xform(x_dir)
		var space_state = state.get_space_state()
		var param = PhysicsShapeQueryParameters.new()
		param.collision_mask = self.collision_mask
		param.set_shape($CollisionShape.shape)
		param.transform = current_transform
		param.exclude = exclusions
		param.margin = 0.001 # When almost collided
		var motion = space_state.cast_motion(param, run_dir.normalized())
		if not can_move_without_collision(motion):
			queue_free()
		state.set_linear_velocity(run_dir)
	state.set_angular_velocity(zero_dir)

func shadow_casting_enable(enable):
	common_utils.shadow_casting_enable(self, enable)