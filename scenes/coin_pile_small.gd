extends PLDLootable

func make_present():
	.make_present()
	visible = true

func make_absent():
	.make_absent()
	visible = false