extends Spatial
class_name ShaderCache

const SHADER_CACHE_ENABLED = true
const SHADER_CACHE_HIDING_ENABLED = true
const SHADER_CACHE_IGNORE_SKELETONS = false
const STEP = 0.0004
const HALFROW = 40

onready var holder = get_node("shader_cache_holder")
onready var label_container = get_node("HBoxContainer")

var stage = 0

func _ready():
	#refresh() -- will be called on settings ready
	pass

func get_cacheable_items(scn, ignore_skeletons):
	var result = []
	if scn is MeshInstance:
		var sk = null if ignore_skeletons else scn.get_node(scn.get_skeleton_path())
		# Adding materials from MeshInstance's surfaces, if any
		var sc = scn.get_surface_material_count()
		for i in range(0, sc):
			var mat = scn.get_surface_material(i)
			if mat:
				result.append({"material": mat, "skeleton": sk if sk is Skeleton else null, "particles_material": null})
		# Adding materials from MeshInstance's meshes' surfaces, if any
		var mesh = scn.mesh
		if mesh and mesh is Mesh:
			var sc_mesh = mesh.get_surface_count()
			for j in range(0, sc_mesh):
				var mat = mesh.surface_get_material(j)
				if mat:
					result.append({"material": mat, "skeleton": sk if sk is Skeleton else null, "particles_material": null})
	elif scn is Particles:
		var pmat = scn.get_process_material()
		# TODO: add another draw pass materials if they will be used
		var mesh = scn.draw_pass_1
		if mesh and mesh is Mesh:
			var sc_mesh = mesh.get_surface_count()
			for j in range(0, sc_mesh):
				var mat = mesh.surface_get_material(j)
				if mat:
					result.append({"material": mat, "skeleton": null, "particles_material": pmat})

	for ch in scn.get_children():
		var items = get_cacheable_items(ch, ignore_skeletons)
		for item in items:
			result.append(item)
	return result

func make_asset(pos, material, skeleton_path):
	var asset = MeshInstance.new()
	var mname = material.get_name()
	if not mname.empty():
		asset.set_name(mname)
	if skeleton_path:
		asset.set_skeleton_path(skeleton_path)
	asset.mesh = SphereMesh.new()
	asset.mesh.radius = STEP / 4.0
	asset.mesh.height = STEP / 2.0
	holder.add_child(asset)
	asset.translate(Vector3(pos.x, pos.y, 0))
	pos.x = pos.x + STEP
	if pos.x > STEP * HALFROW:
		pos.x = -STEP * HALFROW
		pos.y = pos.y + STEP
	asset.mesh.set_material(material)
	return pos

func make_particles(pos, particles_material, material):
	var particles = Particles.new()
	particles.set_name(particles_material.get_name() + "_" + material.get_name())
	particles.draw_pass_1 = SphereMesh.new()
	particles.draw_pass_1.radius = STEP / 4.0
	particles.draw_pass_1.height = STEP / 2.0
	holder.add_child(particles)
	particles.translate(Vector3(pos.x, pos.y, 0))
	pos.x = pos.x + STEP
	if pos.x > STEP * HALFROW:
		pos.x = -STEP * HALFROW
		pos.y = pos.y + STEP
	particles.draw_pass_1.set_material(material)
	particles.set_process_material(particles_material)
	particles.emitting = true
	particles.restart()
	return pos

func add_material_meshes(pos, scn):
	pos.x = pos.x + STEP / 2.0
	pos.y = pos.y + STEP / 2.0
	var items = get_cacheable_items(scn, SHADER_CACHE_IGNORE_SKELETONS)
	var rids = {}
	for item in items:
		var material = item["material"]
		var skeleton = item["skeleton"]
		var particles_material = item["particles_material"]
		var id = material.get_rid().get_id()
		if not rids.has(id):
			rids[id] = true
			pos = make_asset(pos, material, null)
		if skeleton:
			var skeleton_path = skeleton.get_path()
			pos = make_asset(pos, material, skeleton_path)
		if particles_material:
			var pid = particles_material.get_rid().get_id()
			if not rids.has(pid):
				rids[pid] = true
				pos = make_particles(pos, particles_material, material)
	return pos

func _process(delta):
	match stage:
		0:
			pass
		1:
			stage = stage + 1
			label_container.visible = true
			for node in holder.get_children():
				node.queue_free()
			get_tree().call_group("room_enablers", "set_active", false)
		2:
			stage = stage + 1
			var pos = Vector2(-STEP * HALFROW, 0)
			pos = add_material_meshes(pos, get_node("/root"))
		_:
			if SHADER_CACHE_HIDING_ENABLED:
				for node in holder.get_children():
					var sk = node.get_node(node.get_skeleton_path()) if not SHADER_CACHE_IGNORE_SKELETONS and node is MeshInstance else null
					if sk is Skeleton:
						node.queue_free()
					else:
						node.visible = false
				label_container.visible = false
			get_tree().call_group("room_enablers", "set_active", true)
			stage = 0

func refresh():
	if SHADER_CACHE_ENABLED:
		stage = 1
	else:
		label_container.visible = false
		get_tree().call_group("room_enablers", "set_active", true)