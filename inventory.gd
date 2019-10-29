extends ColorRect

var need_restore = false

func _ready():
	get_tree().get_root().connect("size_changed", self, "on_viewport_resize")
	on_viewport_resize()

func on_viewport_resize():
	if not need_restore:
		need_restore = visible
		hide()

func _process(delta):
	if not need_restore:
		return
	show()
	need_restore = false
