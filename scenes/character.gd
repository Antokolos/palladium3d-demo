extends Spatial

export var look_anim_name = "female_rest_99"
export var walk_anim_name = "female_walk_2"

var simple_mode = true

func set_simple_mode(sm):
	simple_mode = sm
	$AnimationTree.active = not simple_mode
	if simple_mode:
		look(0)

func normalize_angle(look_angle_deg):
	return look_angle_deg if abs(look_angle_deg) < 45.0 else (45.0 if look_angle_deg > 0 else -45.0)

func rotate_head(look_angle_deg):
	$AnimationTree.set("parameters/Blend2_Head/blend_amount", 0.5 + 0.5 * (normalize_angle(look_angle_deg) / 45.0))

func set_transition(t):
	var transition = $AnimationTree.get("parameters/Transition/current")
	if transition != t:
		$AnimationTree.set("parameters/Transition/current", t)
		get_anim_player().play(get_anim_name_by_transition(t))

func get_anim_player():
	return $AnimationTree.get_node($AnimationTree.get_animation_player())

func get_anim_name_by_transition(t):
	match t:
		0:
			return look_anim_name
		1:
			return walk_anim_name
		_:
			return look_anim_name

func look(look_angle_deg):
	if not simple_mode:
		rotate_head(look_angle_deg)
	set_transition(0)

func walk(look_angle_deg):
	if not simple_mode:
		rotate_head(look_angle_deg)
	set_transition(1)

func _process(delta):
	if not simple_mode:
		return
	var player = get_node("../../..")
	if player.is_walking:
		walk(0)
	else:
		look(0)