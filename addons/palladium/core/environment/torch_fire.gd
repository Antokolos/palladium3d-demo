extends Spatial

onready var flames = $flames
onready var smoke = $smoke
onready var simple_mode = false
onready var extinguish_timer = $ExtinguishTimer

func is_simple_mode():
	return simple_mode

func set_simple_mode(enable):
	simple_mode = enable
	if enable:
		flames.set_amount(4)
		smoke.set_amount(2)
	else:
		match settings.quality:
			settings.QUALITY_NORM:
				set_quality_normal()
			settings.QUALITY_OPT:
				set_quality_optimal()
			settings.QUALITY_GOOD:
				set_quality_good()
			settings.QUALITY_HIGH:
				set_quality_high()
			_:
				set_quality_optimal()

func is_cpu_particles():
	return flames is CPUParticles or smoke is CPUParticles

func enable(enable):
	flames.emitting = enable
	smoke.emitting = enable
	if not enable:
		if extinguish_timer.is_stopped() and is_cpu_particles():
			extinguish_timer.start()
	else:
		extinguish_timer.stop()
		visible = true
		flames.restart()
		smoke.restart()

func decrease_flame():
	flames.lifetime = 0.2
	smoke.lifetime = 0.3

func restore_flame():
	flames.lifetime = 0.5
	smoke.lifetime = 0.6

func set_quality_normal():
	flames.set_amount(8)
	smoke.set_amount(4)

func set_quality_optimal():
	flames.set_amount(16)
	smoke.set_amount(8)

func set_quality_good():
	flames.set_amount(16)
	smoke.set_amount(8)

func set_quality_high():
	flames.set_amount(32)
	smoke.set_amount(16)

func _on_ExtinguishTimer_timeout():
	visible = false