extends Light

var flicker = true
var moving = true
var prev_translate = null

var translate_step = 0
const TRANSLATE_STEPS_MAX = 15

func _ready():
	randomize()

func enable(enable):
	visible = enable

func set_quality_normal():
	flicker = false
	moving = false

func set_quality_optimal():
	flicker = true
	moving = false

func set_quality_good():
	flicker = true
	moving = true

func set_quality_high():
	flicker = true
	moving = true

func _process(delta):
	if flicker:
		light_energy = rand_range(0.92, 1.0)
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