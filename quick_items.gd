extends HBoxContainer

var need_restore = false
var stage = 0

func mark_restore():
	if not need_restore:
		need_restore = visible
		stage = 0
		hide()

func _process(delta):
	if not need_restore:
		return
	match stage:
		0:
			show()
			stage = stage + 1
		1:
			hide()
			stage = stage + 1
		_:
			show()
			need_restore = false
			stage = 0
