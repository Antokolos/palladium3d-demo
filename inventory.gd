extends ColorRect

var need_restore = false

func _ready():
	get_tree().get_root().connect("size_changed", self, "on_viewport_resize")
	on_viewport_resize()

func get_arrow_size(viewport_size):
	match int(viewport_size.y):
		576:
			return Vector2(80, 121)
		720:
			return Vector2(100, 146)
		1080:
			return Vector2(180, 206)
		_:
			var multiplier = viewport_size.y / 1080.0
			return Vector2(180 * multiplier, 206 * multiplier)

func on_viewport_resize():
	var arrow_size = get_arrow_size(get_viewport_rect().size)
	get_node("HBoxContainer/ArrowLeft").set_custom_minimum_size(arrow_size)
	get_node("HBoxContainer/ArrowRight").set_custom_minimum_size(arrow_size)
	if not need_restore:
		need_restore = visible
		hide()

func _process(delta):
	if not need_restore:
		return
	show()
	need_restore = false
