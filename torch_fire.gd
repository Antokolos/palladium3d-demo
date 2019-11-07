extends Spatial

onready var flames = $flames
onready var smoke = $smoke

func enable(enable):
	flames.emitting = enable
	smoke.emitting = enable
	if not enable:
		if $ExtinguishTimer.is_stopped():
			$ExtinguishTimer.start()
	else:
		$ExtinguishTimer.stop()
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