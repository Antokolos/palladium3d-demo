extends PLDGameWindow
class_name PLDViewportHack

# See https://github.com/godotengine/godot/issues/17326
func do_input(event):
	var r = .do_input(event)
	if get_tree().paused:
		return r
	if event is InputEventMouse:
		var mouseEvent = event.duplicate()
		var viewport_size = $Viewport.size
		var root_viewport_size = get_viewport().size
		mouseEvent.position.x = (viewport_size.x / root_viewport_size.x) * event.global_position.x
		mouseEvent.position.y = (viewport_size.y / root_viewport_size.y) * event.global_position.y
		$Viewport.unhandled_input(mouseEvent)
	else:
		$Viewport.unhandled_input(event)
	return r