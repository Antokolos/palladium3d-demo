extends VBoxContainer

var nam = null
var model_path = null

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