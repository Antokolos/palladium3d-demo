extends Control

onready var viewport = $ViewportContainer/Viewport

func _ready():
	# Required to change the 3D viewport's size when the window is resized.
	get_viewport().connect("size_changed", self, "_root_viewport_size_changed")

# Called when the root's viewport size changes (i.e. when the window is resized).
# This is done to handle multiple resolutions without losing quality.
func _root_viewport_size_changed():
	# The viewport is resized depending on the window height.
	# To compensate for the larger resolution, the viewport sprite is scaled down.
	viewport.size = get_viewport().size