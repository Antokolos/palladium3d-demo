extends PanelContainer

signal item_removed(item)

const BORDER_COLOR = Color(0, 1, 1, 1)
const TRANSPARENT_COLOR = Color(0, 1, 1, 0)

var nam = null
var item_image = null
var model_path = null

func _ready():
	get_tree().get_root().connect("size_changed", self, "on_viewport_resize")
	on_viewport_resize()

func set_item_data(item_data):
	self.nam = item_data.nam
	self.item_image = item_data.item_image
	self.model_path = item_data.model_path
	var image_file = "res://assets/items/%s" % item_image
	var image = load(image_file)
	var texture = ImageTexture.new()
	texture.create_from_image(image)
	get_node("ItemBox/TextureRect").texture = texture
	get_node("ItemBox/LabelDesc").text = tr(nam)

func clear_item():
	self.nam = null
	self.item_image = null
	self.model_path = null
	get_node("ItemBox/TextureRect").texture = null
	get_node("ItemBox/LabelDesc").text = ""

func get_control_sizes(viewport_size):
	var multiplier = viewport_size.y / 576.0
	return [Vector2(125 * multiplier, 125 * multiplier), Vector2(69 * multiplier, 69 * multiplier)]

func set_selected(selected):
	var panel = get("custom_styles/panel")
	panel.set_border_color(BORDER_COLOR if selected else TRANSPARENT_COLOR)

func on_viewport_resize():
	var control_sizes = get_control_sizes(get_viewport_rect().size)
	set_custom_minimum_size(control_sizes[0])
	get_node("ItemBox").set_custom_minimum_size(control_sizes[0])
	get_node("ItemBox/TextureRect").set_custom_minimum_size(control_sizes[1])

func coord_mult(vec1, vec2):
	return Vector3(vec1.x * vec2.x, vec1.y * vec2.y, vec1.z * vec2.z)

func get_aabb(inst):
	if not inst is Spatial:
		return null
	var aabb = inst.get_aabb() if inst is VisualInstance else null
	for ch in inst.get_children():
		var aabb_ch = get_aabb(ch)
		if not aabb_ch:
			continue
		aabb = aabb.merge(aabb_ch) if aabb else aabb_ch
	return AABB(coord_mult(inst.scale, aabb.position), coord_mult(inst.scale, aabb.size)) if aabb else null

func get_model_instance():
	var instance = load(model_path) if model_path else null
	return instance.instance() if instance else null

func remove():
	game_params.remove(nam)
	emit_signal("item_removed", self)
