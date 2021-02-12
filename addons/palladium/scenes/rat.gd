extends PLDTakable
class_name TakableRat

signal state_changed(rat, state_new, state_prev)

onready var rat = (
	get_node("Model").get_child(0)
		if has_node("Model") and get_node("Model").get_child_count() > 0
		else null
)

const RAT_MODEL_ERROR = "Rat model not set"
const SAFE_RANGE = 6
const SNIFF_RANGE = 5
const WARN_RANGE = 3
const RETREAT_RANGE = 1
const ALIGNMENT_RANGE = 0.2

enum RatState {
	REST = 0,
	REST_SNIFF = 1,
	SITS_SNIFF = 2,
	RETREATING = 3
}

onready var player_sqeak = $PlayerSqueak
onready var player_rustle = $PlayerRustle

var x_dir = Vector3(4, 0, 0)
var state = RatState.REST

func use(player_node, camera_node):
	PREFS.set_achievement("RAT_TERROR")
	MEDIA.play_sound(MEDIA.SoundId.RAT_SQUEAK)
	return .use(player_node, camera_node)

func can_move_without_collision(motion):
	# This condition WAS CORRECTED after switching to 3.1, see here:
	# https://github.com/godotengine/godot/issues/21212
	return motion[0] == 1.0 and motion[1] == 1.0

func _integrate_forces(state):
	if not is_present():
		return
	var player = game_state.get_player()
	if not player:
		return
	var current_transform = get_global_transform()
	var current_position = current_transform.origin
	var player_position = player.get_global_transform().origin
	var dir = player_position - current_position
	var l = dir.length()
	state.set_linear_velocity(Vector3.ZERO)
	var retreating = is_retreating()
	if not retreating and l > SAFE_RANGE:
		if player_rustle.is_playing():
			player_rustle.stop()
		rest()
	elif not retreating and l > SNIFF_RANGE:
		if not player_rustle.is_playing():
			player_rustle.play()
		rest_sniff()
	elif not retreating and l > WARN_RANGE:
		if not player_rustle.is_playing():
			player_rustle.play()
		sits_sniff()
	elif retreating or l > RETREAT_RANGE:
		if not retreating:
			player_rustle.stop()
			player_sqeak.play()
		run()
		var run_dir = current_transform.basis.xform(x_dir)
		var space_state = state.get_space_state()
		var param = PhysicsShapeQueryParameters.new()
		param.collision_mask = self.collision_mask
		param.set_shape($CollisionShape.shape)
		param.transform = current_transform
		#param.exclude = [ self ]
		param.margin = 0.001 # When almost collided
		var motion = space_state.cast_motion(param, run_dir.normalized())
		if not can_move_without_collision(motion):
			queue_free()
		state.set_linear_velocity(run_dir)
	state.set_angular_velocity(Vector3.ZERO)

func is_retreating():
	return state == RatState.RETREATING

func is_close_to(body):
	if not body:
		return false
	var rat_origin = get_global_transform().origin
	var body_origin = body.get_global_transform().origin
	return rat_origin.distance_to(body_origin) < SAFE_RANGE

func make_present():
	.make_present()
	set_mode(RigidBody.MODE_RIGID)

func make_absent():
	set_mode(RigidBody.MODE_STATIC)
	.make_absent()

func rest():
	if state == RatState.REST:
		return
	var state_prev = state
	state = RatState.REST
	rat.rest() if rat else push_error(RAT_MODEL_ERROR)
	emit_signal("state_changed", self, state, state_prev)

func rest_sniff():
	if state == RatState.REST_SNIFF:
		return
	var state_prev = state
	state = RatState.REST_SNIFF
	rat.rest_sniff() if rat else push_error(RAT_MODEL_ERROR)
	emit_signal("state_changed", self, state, state_prev)

func sits_sniff():
	if state == RatState.SITS_SNIFF:
		return
	var state_prev = state
	state = RatState.SITS_SNIFF
	rat.sits_sniff() if rat else push_error(RAT_MODEL_ERROR)
	emit_signal("state_changed", self, state, state_prev)

func run():
	if state == RatState.RETREATING:
		return
	var state_prev = state
	state = RatState.RETREATING
	rat.run() if rat else push_error(RAT_MODEL_ERROR)
	emit_signal("state_changed", self, state, state_prev)

func shadow_casting_enable(enable):
	common_utils.shadow_casting_enable(self, enable)
