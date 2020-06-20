extends Spatial
class_name PLDCharacterModel

signal cutscene_finished(player, cutscene_id)

const CUTSCENE_EMPTY = 0

const LOOK_TRANSITION_STAND_UP = 0
const LOOK_TRANSITION_STANDING = 1
const LOOK_TRANSITION_SIT_DOWN = 2
const LOOK_TRANSITION_SQUATTING = 3

const TRANSITION_LOOK = 0
const TRANSITION_WALK = 1
const TRANSITION_RUN = 2
const TRANSITION_CROUCH = 3

const REST_POSE_CHANGE_TIME_S = 7

export var main_skeleton = "Female_palladium_armature"

export var rest_shots_max = 2

var simple_mode = false

func _ready():
	randomize()

func ragdoll_start():
	$AnimationTree.set_active(false)
	get_node(main_skeleton).physical_bones_start_simulation()

func ragdoll_stop():
	get_node(main_skeleton).physical_bones_stop_simulation()
	$AnimationTree.set_active(true)

func set_simple_mode(sm):
	simple_mode = sm
	if simple_mode:
		look(0)

func can_do_rest_shot():
	return not is_rest_active() and not is_in_speak_mode() and not is_sitting()

func do_rest_shot(shot_idx):
	if can_do_rest_shot():
		$AnimationTree.set("parameters/RestTransition/current", shot_idx)
		$AnimationTree.set("parameters/RestShot/active", true)

func stop_rest_shot():
	$AnimationTree.set("parameters/RestShot/active", false)

func is_rest_active():
	return $AnimationTree.get("parameters/RestShot/active")

func is_in_speak_mode():
	return conversation_manager.conversation_is_in_progress()

func play_cutscene(cutscene_id):
	$AnimationTree.set("parameters/CutsceneTransition/current", cutscene_id)
	$AnimationTree.set("parameters/CutsceneShot/active", true)

func stop_cutscene():
	$AnimationTree.set("parameters/CutsceneTransition/current", CUTSCENE_EMPTY)
	$AnimationTree.set("parameters/CutsceneShot/active", false)

func is_cutscene():
	if $AnimationTree.get("parameters/LookTransition/current") > LOOK_TRANSITION_SQUATTING:
		return true
	var cutscene_empty = $AnimationTree.get("parameters/CutsceneTransition/current") == CUTSCENE_EMPTY
	return not cutscene_empty and $AnimationTree.get("parameters/CutsceneShot/active")

func set_look_transition(look_transition):
	$AnimationTree.set("parameters/LookTransition/current", look_transition)

func is_standing():
	return $AnimationTree.get("parameters/LookTransition/current") == LOOK_TRANSITION_STANDING

func is_sitting():
	return $AnimationTree.get("parameters/LookTransition/current") == LOOK_TRANSITION_SQUATTING

func stand_up():
	if not is_standing():
		$AnimationTree.set("parameters/LookTransition/current", LOOK_TRANSITION_STAND_UP)

func sit_down():
	if not is_sitting():
		$AnimationTree.set("parameters/LookTransition/current", LOOK_TRANSITION_SIT_DOWN)

func normalize_angle(look_angle_deg):
	return look_angle_deg if abs(look_angle_deg) < 45.0 else (45.0 if look_angle_deg > 0 else -45.0)

func rotate_head(look_angle_deg):
	$AnimationTree.set("parameters/Blend2_Head/blend_amount", 0.5 + 0.5 * (normalize_angle(look_angle_deg) / 45.0))

func take_damage():
	$AnimationTree.set("parameters/DamageShot/active", true)

func set_transition(t):
	var transition = $AnimationTree.get("parameters/Transition/current")
	if transition != t:
		$AnimationTree.set("parameters/Transition/current", t)

func look(look_angle_deg):
	rotate_head(look_angle_deg)
	set_transition(TRANSITION_LOOK)
	if can_do_rest_shot() and $RestTimer.is_stopped():
		$RestTimer.start(REST_POSE_CHANGE_TIME_S)

func walk(look_angle_deg, is_crouching = false, is_sprinting = false):
	rotate_head(look_angle_deg)
	set_transition(TRANSITION_CROUCH if is_crouching else (TRANSITION_RUN if is_sprinting else TRANSITION_WALK))
	$RestTimer.stop()
	stop_rest_shot()

func activate(enable):
	pass

func _process(delta):
	if not simple_mode:
		if not is_cutscene():
			var cutscene_id = $AnimationTree.get("parameters/CutsceneTransition/current")
			if cutscene_id > CUTSCENE_EMPTY:
				var player = get_node("../..")
				emit_signal("cutscene_finished", player, cutscene_id)
		return

func get_shot_idx(shots_max):
	var shot_span = 1.0 / shots_max
	var shot_idx = int(floor(randf() / shot_span))
	if shot_idx == shots_max:
		shot_idx = shot_idx - 1
	return shot_idx

func _on_RestTimer_timeout():
	do_rest_shot(get_shot_idx(rest_shots_max))
