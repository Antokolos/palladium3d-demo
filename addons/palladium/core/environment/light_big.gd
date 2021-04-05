extends OmniLight

var shadow = true
var flicker = true
var moving = true
var prev_translate = null
var max_light = 1.0

var translate_step = 0
const TRANSLATE_STEPS_MAX = 15

func _ready():
	randomize()

func enable(enable):
	visible = enable

func enable_shadow_if_needed(enable):
	set_shadow(shadow and enable)

func decrease_light():
	omni_range = 5.7
	max_light = 0.5
	light_energy = max_light

func restore_light():
	omni_range = 8.0
	max_light = 1.0
	light_energy = max_light

func set_quality_normal():
	shadow = false
	set_shadow(shadow)
	flicker = false
	moving = false

func set_quality_optimal():
	shadow = true
	set_shadow(shadow)
	flicker = false
	moving = false

func set_quality_good():
	shadow = true
	set_shadow(shadow)
	flicker = true
	moving = false

func set_quality_high():
	shadow = true
	set_shadow(shadow)
	flicker = true
	moving = true

func _process(delta):
	if not game_state.is_level_ready():
		return
	if flicker:
		light_energy = rand_range(0.92 * max_light, max_light)
	if moving:
		if not prev_translate or translate_step >= TRANSLATE_STEPS_MAX:
			if prev_translate:
				translate_object_local(-prev_translate)
			var x = rand_range(-0.003, 0.003)
			var y = rand_range(-0.003, 0.003)
			var z = rand_range(-0.003, 0.003)
			prev_translate = Vector3(x, y, z)
			translate_step = 0
		translate_object_local(prev_translate / TRANSLATE_STEPS_MAX)
		translate_step = translate_step + 1
	elif translate_step > 0:
		if prev_translate:
			translate_object_local(-prev_translate * translate_step / TRANSLATE_STEPS_MAX)
			prev_translate = null