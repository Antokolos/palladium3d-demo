extends Light

func enable(enable):
	visible = enable

func set_quality_normal():
	enable(true)
	set_shadow(false)

func set_quality_optimal():
	enable(true)
	set_shadow(true)

func set_quality_good():
	enable(true)
	set_shadow(true)

func set_quality_high():
	enable(true)
	set_shadow(true)