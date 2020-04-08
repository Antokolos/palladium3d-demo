extends Viewport

func _ready():
	get_viewport().connect("size_changed", self, "_root_viewport_size_changed")
	settings.connect("resolution_changed", self, "_on_resolution_changed")
	_on_resolution_changed(settings.resolution)
	
func _root_viewport_size_changed():
	_on_resolution_changed(settings.resolution)

func _on_resolution_changed(ID):
	var size = settings.get_resolution_size(ID)
	self.size = size
	self.set_size_override(true, size)
