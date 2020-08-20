extends Spatial
class_name PLDCharacterModel

signal cutscene_finished(player, cutscene_id)
signal character_dead(player)

const CUTSCENE_EMPTY = 0

const LOOK_TRANSITION_STAND_UP = 0
const LOOK_TRANSITION_STANDING = 1
const LOOK_TRANSITION_SIT_DOWN = 2
const LOOK_TRANSITION_SQUATTING = 3

const DAMAGE_TRANSITION_FATAL = 0
const DAMAGE_TRANSITION_JUMPSCARE = 1
const DAMAGE_TRANSITION_NORMAL = 2

const ALIVE_TRANSITION_ALIVE = 0
const ALIVE_TRANSITION_DEAD = 1

const TRANSITION_LOOK = 0
const TRANSITION_WALK = 1
const TRANSITION_RUN = 2
const TRANSITION_CROUCH = 3

const REST_POSE_CHANGE_TIME_S = 7
const ROTATE_HEAD_ANGLE_TOLERANCE_DEG = 2.0

export var main_skeleton = "Female_palladium_armature"

export var rest_shots_max = 2
export var ragdoll_enabled = false

onready var animation_tree = $AnimationTree
onready var transition = animation_tree.get("parameters/Transition/current")
onready var rest_timer = $RestTimer

var look_angle_cur_deg = 0
var simple_mode = false
var was_dying = false

func _ready():
	randomize()
	ragdoll_stop()

func activate():
	pass

func ragdoll_start():
	animation_tree.set_active(false)
	get_node(main_skeleton).physical_bones_start_simulation()

func ragdoll_stop():
	get_node(main_skeleton).physical_bones_stop_simulation()
	animation_tree.set_active(true)

func set_simple_mode(sm):
	simple_mode = sm
	if simple_mode:
		look()

func can_do_rest_shot():
	return not is_rest_active() and not is_in_speak_mode() and not is_sitting()

func do_rest_shot(shot_idx):
	if can_do_rest_shot():
		animation_tree.set("parameters/RestTransition/current", shot_idx)
		animation_tree.set("parameters/RestShot/active", true)

func stop_rest_shot():
	animation_tree.set("parameters/RestShot/active", false)

func is_rest_active():
	return animation_tree.get("parameters/RestShot/active")

func is_in_speak_mode():
	return conversation_manager.conversation_is_in_progress()

func play_cutscene(cutscene_id):
	animation_tree.set("parameters/CutsceneTransition/current", cutscene_id)
	animation_tree.set("parameters/CutsceneShot/active", true)

func stop_cutscene():
	animation_tree.set("parameters/CutsceneTransition/current", CUTSCENE_EMPTY)
	animation_tree.set("parameters/CutsceneShot/active", false)

func is_movement_disabled():
	return is_cutscene() or is_dead() or is_taking_damage()

func is_dying():
	return is_taking_damage() and animation_tree.get("parameters/AliveTransition/current") == ALIVE_TRANSITION_DEAD

func is_dead():
	return not is_taking_damage() and animation_tree.get("parameters/AliveTransition/current") == ALIVE_TRANSITION_DEAD

func is_taking_damage():
	return animation_tree.get("parameters/DamageShot/active")

func is_cutscene():
	if animation_tree.get("parameters/LookTransition/current") > LOOK_TRANSITION_SQUATTING:
		return true
	var cutscene_empty = animation_tree.get("parameters/CutsceneTransition/current") == CUTSCENE_EMPTY
	return not cutscene_empty and animation_tree.get("parameters/CutsceneShot/active")

func set_look_transition(look_transition):
	animation_tree.set("parameters/LookTransition/current", look_transition)

func is_standing():
	return animation_tree.get("parameters/LookTransition/current") == LOOK_TRANSITION_STANDING

func is_sitting():
	return animation_tree.get("parameters/LookTransition/current") == LOOK_TRANSITION_SQUATTING

func stand_up():
	if not is_standing():
		animation_tree.set("parameters/LookTransition/current", LOOK_TRANSITION_STAND_UP)

func sit_down():
	if not is_sitting():
		animation_tree.set("parameters/LookTransition/current", LOOK_TRANSITION_SIT_DOWN)

func normalize_angle(look_angle_deg):
	return look_angle_deg if abs(look_angle_deg) < 45.0 else (45.0 if look_angle_deg > 0 else -45.0)

func rotate_head(look_angle_deg):
	var la = normalize_angle(look_angle_deg)
	if la < look_angle_cur_deg - ROTATE_HEAD_ANGLE_TOLERANCE_DEG \
		or la > look_angle_cur_deg + ROTATE_HEAD_ANGLE_TOLERANCE_DEG:
		look_angle_cur_deg = la
		animation_tree.set("parameters/Blend2_Head/blend_amount", 0.5 + 0.5 * (la / 45.0))

func take_damage(fatal):
	var alive = not is_dead()
	if alive and ragdoll_enabled and fatal:
		ragdoll_start()
		return
	var dt = DAMAGE_TRANSITION_JUMPSCARE if not alive else DAMAGE_TRANSITION_FATAL if fatal else DAMAGE_TRANSITION_NORMAL
	animation_tree.set("parameters/DamageTransition/current", dt)
	animation_tree.set("parameters/DamageShot/active", true)
	if alive and fatal:
		animation_tree.set("parameters/AliveTransition/current", ALIVE_TRANSITION_DEAD)

func set_transition(t):
	if transition != t:
		transition = t
		animation_tree.set("parameters/Transition/current", t)

func look():
	set_transition(TRANSITION_LOOK)
	if can_do_rest_shot() and rest_timer.is_stopped():
		rest_timer.start(REST_POSE_CHANGE_TIME_S)

func walk(is_crouching = false, is_sprinting = false):
	set_transition(TRANSITION_CROUCH if is_crouching else (TRANSITION_RUN if is_sprinting else TRANSITION_WALK))
	rest_timer.stop()
	stop_rest_shot()

func _process(delta):
	if not simple_mode:
		if not is_cutscene():
			var cutscene_id = animation_tree.get("parameters/CutsceneTransition/current")
			if cutscene_id > CUTSCENE_EMPTY:
				var player = get_node("../..")
				emit_signal("cutscene_finished", player, cutscene_id)
		if was_dying and is_dead():
			var player = get_node("../..")
			emit_signal("character_dead", player)
		was_dying = is_dying()

func get_shot_idx(shots_max):
	var shot_span = 1.0 / shots_max
	var shot_idx = int(floor(randf() / shot_span))
	if shot_idx == shots_max:
		shot_idx = shot_idx - 1
	return shot_idx

func _on_RestTimer_timeout():
	do_rest_shot(get_shot_idx(rest_shots_max))
