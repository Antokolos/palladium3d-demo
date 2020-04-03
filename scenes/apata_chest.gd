extends ItemContainer
class_name ApataChest

const PUSH_DIR = Vector3(0, 0, -1)
const PUSH_SPEED = 0.85
const PUSH_W = 1.15

var is_pushing = false

func _physics_process(delta):
	if is_pushing and game_params.story_vars.apata_chest_rigid > 0 and mode != RigidBody.MODE_RIGID:
		set_mode(RigidBody.MODE_RIGID)
	elif game_params.story_vars.apata_chest_rigid <= 0 and mode != RigidBody.MODE_STATIC:
		set_mode(RigidBody.MODE_STATIC)

func _integrate_forces(state):
	if is_pushing and game_params.story_vars.apata_chest_rigid > 0 and mode == RigidBody.MODE_RIGID:
		var cur_dir = get_global_transform().basis.xform(PUSH_DIR)
		state.set_linear_velocity(cur_dir * PUSH_SPEED * (sin(PUSH_W * OS.get_ticks_msec()) + 0.8))

func do_push():
	is_pushing = true
	var cur_dir = get_global_transform().basis.xform(PUSH_DIR)
	apply_central_impulse(cur_dir)
