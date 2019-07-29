extends Spatial

onready var flames = $flames
onready var smoke = $smoke

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