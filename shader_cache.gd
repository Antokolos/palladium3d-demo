extends Spatial

const SHADER_CACHE_ENABLED = false
const SHADER_CACHE_HIDING_ENABLED = true
const STEP = 0.0004
const HALFROW = 40

var stage = 0

func _ready():
	#refresh() -- will be called on settings ready
	pass

func get_cacheable_items(scn):
	var result = []
	if scn is MeshInstance:
		var sk_path = scn.get_skeleton_path()
		var sk = scn.get_node(sk_path)
		# Adding materials from MeshInstance's surfaces, if any
		var sc = scn.get_surface_material_count()
		for i in range(0, sc):
			var mat = scn.get_surface_material(i)
			if mat:
				result.append({"material": mat, "skeleton": sk if sk is Skeleton else null})
		# Adding materials from MeshInstance's meshes' surfaces, if any
		var mesh = scn.mesh
		if mesh and mesh is Mesh:
			var sc_mesh = mesh.get_surface_count()
			for j in range(0, sc_mesh):
				var mat = mesh.surface_get_material(j)
				if mat:
					result.append({"material": mat, "skeleton": sk if sk is Skeleton else null})
	for ch in scn.get_children():
		var items = get_cacheable_items(ch)
		for item in items:
			result.append(item)
	return result

func make_asset(pos, material, skeleton_path):
	var asset = MeshInstance.new()
	if skeleton_path:
		asset.set_skeleton_path(skeleton_path)
	asset.mesh = SphereMesh.new()
	asset.mesh.radius = STEP / 4.0
	asset.mesh.height = STEP / 2.0
	add_child(asset)
	asset.translate(Vector3(pos.x, pos.y, 0))
	pos.x = pos.x + STEP
	if pos.x > STEP * HALFROW:
		pos.x = -STEP * HALFROW
		pos.y = pos.y + STEP
	asset.mesh.set_material(material)
	return pos

func add_material_meshes(pos, scn):
	pos.x = pos.x + STEP / 2.0
	pos.y = pos.y + STEP / 2.0
	var items = get_cacheable_items(scn)
	var rids = {}
	for item in items:
		var material = item["material"]
		var skeleton = item["skeleton"]
		var id = material.get_rid().get_id()
		if not rids.has(id):
			rids[id] = true
			pos = make_asset(pos, material, null)
		if skeleton:
			var skeleton_path = skeleton.get_path()
			pos = make_asset(pos, material, skeleton_path)
	return pos

func _process(delta):
	match stage:
		0:
			pass
		1:
			stage = stage + 1
			self.visible = true
			for node in get_children():
				node.queue_free()
		2:
			stage = stage + 1
			var pos = Vector2(-STEP * HALFROW, 0)
			pos = add_material_meshes(pos, get_node("/root"))
		_:
			if SHADER_CACHE_HIDING_ENABLED:
				self.visible = false
			stage = 0

func refresh():
	if SHADER_CACHE_ENABLED:
		stage = 1