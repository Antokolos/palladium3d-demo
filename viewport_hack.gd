extends ViewportContainer

onready var viewport = $Viewport

# See https://github.com/godotengine/godot/issues/17326
func _input(event):
	if event is InputEventMouse:
		var mouseEvent = event.duplicate()
		var viewport_size = viewport.size
		var root_viewport_size = get_viewport().size
		mouseEvent.position.x = (viewport_size.x / root_viewport_size.x) * event.global_position.x
		mouseEvent.position.y = (viewport_size.y / root_viewport_size.y) * event.global_position.y
		viewport.unhandled_input(mouseEvent)
	else:
		viewport.unhandled_input(event)