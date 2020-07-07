extends Spatial
class_name PLDMenuItem

export var text_path = "Text023"
export var sfx_player_over_path = "../../SFXOver"
export var emission_enabled = true
export var emission_energy = 0.05
export var activation_lang_id = settings.LANGUAGE_EN
onready var menu_item_normal = SpatialMaterial.new()
onready var menu_item_highlight = SpatialMaterial.new()
onready var text_node = get_node(text_path)
onready var sfx_player_over = get_node(sfx_player_over_path)
onready var static_body = get_node("StaticBody")

var is_mouse_over = false

func _ready():
	menu_item_normal.set("albedo_color", Color("#FFFFFF"))
	menu_item_normal.set("metallic", 0.9)
	menu_item_normal.set("roughness", 0.1)
	menu_item_normal.set("emission_enabled", emission_enabled)
	if emission_enabled:
		menu_item_normal.set("emission", Color("#FFFFFF"))
		menu_item_normal.set("emission_energy", emission_energy)
	menu_item_highlight.set("albedo_color", Color("#EC6418"))
	menu_item_highlight.set("metallic", 0.1)
	menu_item_highlight.set("roughness", 0.9)
	menu_item_highlight.set("emission_enabled", true)
	menu_item_highlight.set("emission", Color("EC6418"))
	text_node.set_surface_material(0, menu_item_normal)
	settings.connect("language_changed", self, "_on_language_changed")
	static_body.connect("input_event", self, "_on_StaticBody_input_event")
	static_body.connect("mouse_entered", self, "_on_StaticBody_mouse_entered")
	static_body.connect("mouse_exited", self, "_on_StaticBody_mouse_exited")
	is_mouse_over = false

func _on_language_changed(lang_id):
	var active = lang_id == activation_lang_id
	visible = active
	get_node("StaticBody/CollisionShape").disabled = not active

func click():
	pass

func mouse_over():
	text_node.set_surface_material(0, menu_item_highlight)
	sfx_player_over.play()
	is_mouse_over = true

func mouse_out():
	text_node.set_surface_material(0, menu_item_normal)
	is_mouse_over = false

func _on_StaticBody_input_event(camera, event, click_position, click_normal, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		click()

func _on_StaticBody_mouse_entered():
	mouse_over()

func _on_StaticBody_mouse_exited():
	mouse_out()