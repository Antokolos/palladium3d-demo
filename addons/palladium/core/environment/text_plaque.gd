extends Spatial

export var text_en = "Text"
export var text_ru = "Текст"
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
	match (settings.language):
		settings.LANGUAGE_EN:
			label.text = text_en
		settings.language_RU:
			label.text = text_ru
		_:
			label.text = text_en
