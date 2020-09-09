extends Spatial

export var text = "Text"
export var width = 1
export var height = 1
export var pixels_size = 800
export var font_size = 40
export var font_color = Color(1, 1, 1)
#export var font_color_shadow = Color(0, 0, 0)

var is_text_plaque = true
onready var label = get_node("Viewport/Label")
onready var plaque = get_node("plaque")
onready var viewport = get_node("Viewport")

func _ready():
	# The following line is not needed, see https://github.com/godotengine/godot/issues/23750#issuecomment-440708856
	#plaque.material_override.albedo_texture = viewport.get_texture()
	plaque.mesh.size = Vector2(width, height)
	viewport.size = Vector2(int(width * pixels_size), int(height * pixels_size))
	label.get("custom_fonts/font").set_size(font_size)
	label.set("custom_colors/font_color", font_color)
	#label.set("custom_colors/font_color_shadow", font_color_shadow)
	set_text(text)

func set_text(text):
	self.text = text
	label.text = tr(text)