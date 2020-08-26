extends Spatial
class_name PLDShaderCache

const SHADER_CACHE_ENABLED = true
const SHADER_CACHE_HIDING_ENABLED = true
const STEP = 0.005
const HALFROW = 20

var stage = 0
var rids = {}
var skeleton_paths = {}
var character_skeleton_paths = {}

func _ready():
	#refresh() -- will be called on settings ready
	pass

func get_cacheable_items(scn):
	var result = []
	if scn is MeshInstance:
		result.append({"mesh" : scn, "particles": null, "particles_cpu": null})
	elif scn is Particles:
		result.append({"mesh" : null, "particles": scn, "particles_cpu": null})
	elif scn is CPUParticles:
		result.append({"mesh" : null, "particles": null, "particles_cpu": scn})

	for ch in scn.get_children():
		var items = get_cacheable_items(ch)
		for item in items:
			result.append(item)
	return result

func get_scale_from_aabb(aabb):
	var size = aabb.size
	if size.x == 0:
		size.x = 0.001
	if size.y == 0:
		size.y = 0.001
	if size.z == 0:
		size.z = 0.001
	return Vector3(STEP / (2 * size.x), STEP / (2 * size.y), STEP / (2 * size.z))

func make_skeleton(pos, skeleton):
	skeleton.set_transform(Transform())
	skeleton.translate(Vector3(pos.x, pos.y, 0))
	var aabb = AABB(Vector3(0, 0, 0), Vector3(STEP, STEP, STEP))
	for skeleton_child in skeleton.get_children():
		if skeleton_child is VisualInstance:
			aabb = aabb.merge(skeleton_child.get_aabb())
	skeleton.set_scale(get_scale_from_aabb(aabb))
	for ch in skeleton.get_children():
		if ch is AnimationPlayer:
			var anim_list = ch.get_animation_list()
			for anim in anim_list:
				ch.play(anim)
	return skeleton

func make_base_asset(pos, resource):
	var asset = MeshInstance.new()
	asset.set_transform(Transform())
	asset.translate(Vector3(pos.x, pos.y, 0))
	var mname = resource.get_name() if resource else "" 
	if not mname.empty():
		asset.set_name(mname)
	return asset

func make_asset(pos, material):
	var asset = make_base_asset(pos, material)
	asset.mesh = SphereMesh.new()
	asset.mesh.radius = STEP / 4.0
	asset.mesh.height = STEP / 2.0
	asset.mesh.set_material(material)
	return asset

func make_mesh(pos, mesh, surface_materials = []):
	var asset = make_base_asset(pos, mesh)
	asset.mesh = mesh
	var aabb = AABB(Vector3(0, 0, 0), Vector3(STEP, STEP, STEP))
	aabb = aabb.merge(asset.get_aabb())
	asset.set_scale(get_scale_from_aabb(aabb))
	for i in range(surface_materials.size()):
		asset.set_surface_material(i, surface_materials[i])
	return asset

func make_particles(pos, particles):
	particles.set_transform(Transform())
	particles.translate(Vector3(pos.x, pos.y, 0))
	var aabb = AABB(Vector3(0, 0, 0), Vector3(STEP, STEP, STEP))
	aabb = aabb.merge(particles.get_aabb())
	particles.set_scale(get_scale_from_aabb(aabb))
	particles.emitting = true
	particles.restart()
	return particles

func next_pos(pos):
	pos.x = pos.x + STEP
	if pos.x > STEP * HALFROW:
		pos.x = -STEP * HALFROW
		pos.y = pos.y + STEP
	return pos

func add_material_meshes(pos, scn):
	var items = get_cacheable_items(scn)
	pos.x = pos.x + STEP / 2.0
	pos.y = pos.y + STEP / 2.0
	for item in items:
		var mesh = item["mesh"]
		var particles = item["particles"]
		var particles_cpu = item["particles_cpu"]
		if mesh:
			# Adding materials from MeshInstance's surfaces, if any
			var sc = mesh.get_surface_material_count()
			var surface_materials = []
			for i in range(0, sc):
				var mat = mesh.get_surface_material(i)
				if mat:
					surface_materials.append(mat)
					var rid = mat.get_rid().get_id()
					if not rids.has(rid):
						rids[rid] = make_asset(pos, mat)
						self.add_child(rids[rid])
						pos = next_pos(pos)
			# Adding materials from MeshInstance's meshes' surfaces, if any
			var m = mesh.mesh
			if m and m is Mesh:
				var sc_mesh = m.get_surface_count()
				for j in range(0, sc_mesh):
					var mat = m.surface_get_material(j)
					if mat:
						var rid = mat.get_rid().get_id()
						if not rids.has(rid):
							rids[rid] = make_asset(pos, mat)
							self.add_child(rids[rid])
							pos = next_pos(pos)
			
			var mesh_id = m.get_rid().get_id()
			var sk = mesh.get_node(mesh.get_skeleton_path())
			if sk is Skeleton:
				var sk_path = sk.get_path()
				var target_dic = character_skeleton_paths if sk.get_parent() is PLDCharacterModel else skeleton_paths
				if not target_dic.has(sk_path):
					target_dic[sk_path] = make_skeleton(pos, sk.duplicate(Node.DUPLICATE_USE_INSTANCING))
					self.add_child(target_dic[sk_path])
					pos = next_pos(pos)
			if not rids.has(mesh_id):
				rids[mesh_id] = make_mesh(pos, m, surface_materials)
				self.add_child(rids[mesh_id])
				pos = next_pos(pos)
		elif particles:
			var pmat = particles.get_process_material()
			var rid = pmat.get_rid().get_id()
			if not rids.has(rid):
				rids[rid] = make_particles(pos, particles.duplicate(Node.DUPLICATE_USE_INSTANCING))
				self.add_child(rids[rid])
				pos = next_pos(pos)
		elif particles_cpu:
			var pmat = particles_cpu.mesh.material
			var rid = pmat.get_rid().get_id()
			if not rids.has(rid):
				rids[rid] = make_particles(pos, particles_cpu.duplicate(Node.DUPLICATE_USE_INSTANCING))
				self.add_child(rids[rid])
				pos = next_pos(pos)
	return pos

func _process(delta):
	match stage:
		0:
			pass
		1:
			stage = stage + 1
			game_state.get_hud().clear_popup_message()
			game_state.get_hud().set_popup_message(tr("MESSAGE_PLEASE_WAIT"))
			rids.clear()
			skeleton_paths.clear()
			character_skeleton_paths.clear()
			for node in self.get_children():
				node.queue_free()
			get_tree().call_group("room_enablers", "set_active", false)
		2:
			stage = stage + 1
			var pos = Vector2(-STEP * HALFROW, 0)
			pos = add_material_meshes(pos, game_state.get_viewport())
		3:
			stage = stage + 1
			# Show all items for one frame
		_:
			if SHADER_CACHE_HIDING_ENABLED:
				for rid in rids.keys():
					var a = rids[rid]
					#a.visible = false
					self.remove_child(a)
				for sk_path in skeleton_paths.keys():
					var sk = skeleton_paths[sk_path]
					#sk.visible = false
					self.remove_child(sk)
				for character_sk_path in character_skeleton_paths.keys():
					var character_sk = character_skeleton_paths[character_sk_path]
					# Moving all character skeletons to center
					var scale = character_sk.get_scale()
					character_sk.set_transform(Transform())
					character_sk.set_scale(scale)
			game_state.get_hud().clear_popup_message()
			game_state.shader_cache_processed()
			get_tree().call_group("room_enablers", "set_active", true)
			stage = 0

func refresh():
	stage = 1 if SHADER_CACHE_ENABLED else 3
