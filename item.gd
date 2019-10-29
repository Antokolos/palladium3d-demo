extends VBoxContainer

var nam = null
var model_path = null

func _ready():
	get_tree().get_root().connect("size_changed", self, "on_viewport_resize")
	on_viewport_resize()

func get_control_sizes(viewport_size):
	match int(viewport_size.y):
		480:
			return [Vector2(111, 111), Vector2(59, 59)]
		576:
			return [Vector2(131, 131), Vector2(79, 79)]
		720:
			return [Vector2(156, 156), Vector2(104, 104)]
		1080:
			return [Vector2(216, 216), Vector2(164, 164)]
		_:
			var multiplier = viewport_size.y / 1080.0
			return [Vector2(216 * multiplier, 216 * multiplier), Vector2(164 * multiplier, 164 * multiplier)]

func on_viewport_resize():
	var control_sizes = get_control_sizes(get_viewport_rect().size)
	set_custom_minimum_size(control_sizes[0])
	$TextureRect.set_custom_minimum_size(control_sizes[1])

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
	self.queue_free()