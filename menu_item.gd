extends Spatial
class_name MenuItem

export var text_path = "Text023"
export var sfx_player_over_path = "../../SFXOver"
onready var menu_item_normal = SpatialMaterial.new()
onready var menu_item_highlight = SpatialMaterial.new()
onready var text_node = get_node(text_path)
onready var sfx_player_over = get_node(sfx_player_over_path)

func _ready():
	menu_item_normal.set("albedo_color", Color("#FFFFFF"))
	menu_item_normal.set("metallic", 0.9)
	menu_item_normal.set("roughness", 0.1)
	menu_item_highlight.set("albedo_color", Color("#EC6418"))
	menu_item_highlight.set("metallic", 0.1)
	menu_item_highlight.set("roughness", 0.9)
	menu_item_highlight.set("emission_enabled", true)
	menu_item_highlight.set("emission", Color("EC6418"))
	text_node.set_surface_material(0, menu_item_normal)

func mouse_over():
	text_node.set_surface_material(0, menu_item_highlight)
	sfx_player_over.play()

func mouse_out():
	text_node.set_surface_material(0, menu_item_normal)