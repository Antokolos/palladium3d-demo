extends Spatial

const CAMERA_FOV_DEGREES = 55
const STEPS = 2
const ANGLE_COEFF = 0.5
const DISTANCE_COEFF = 0.2

const MIN_DIFF = 0.2

func _ready():
	settings.connect("cutoff_enabled_changed", self, "enable_raycasts")
	init()

func enable_raycasts(enabled):
	for r in get_children():
		r.enabled = enabled

func create_raycast(x, y, z):
	var r = RayCast.new()
	r.enabled = settings.cutoff_enabled
	r.set_collision_mask_bit(0, false)
	r.set_collision_mask_bit(1, true)
	r.cast_to = Vector3(x, y, z)
	return r

func add_raycast(x, y, z):
	add_child(create_raycast(x, y, z))

func get_length_limit():
	return get_camera_limit()

func init():
	var z = -get_length_limit()
	var width_limit = get_length_limit() * tan(deg2rad(CAMERA_FOV_DEGREES / 2.0))
	var height_limit = width_limit
	var xstep = float(width_limit) / float(STEPS)
	var x = xstep
	add_raycast(0, 0, z)
	while x < width_limit + xstep + MIN_DIFF:
		add_raycast(x, 0, z)
		add_raycast(-x, 0, z)
		add_raycast(x, x, z)
		add_raycast(-x, x, z)
		add_raycast(x, -x, z)
		add_raycast(-x, -x, z)
		
		add_raycast(x * ANGLE_COEFF, x, z)
		add_raycast(-x * ANGLE_COEFF, x, z)
		add_raycast(x * ANGLE_COEFF, -x, z)
		add_raycast(-x * ANGLE_COEFF, -x, z)
		add_raycast(x, x * ANGLE_COEFF, z)
		add_raycast(-x, x * ANGLE_COEFF, z)
		add_raycast(x, -x * ANGLE_COEFF, z)
		add_raycast(-x, -x * ANGLE_COEFF, z)
		x = x + xstep
	
	var ystep = float(height_limit) / float(STEPS)
	var y = ystep
	while y < height_limit + ystep + MIN_DIFF:
		add_raycast(0, y, z)
		add_raycast(0, -y, z)
		y = y + ystep

func get_camera_limit():
	return 50 if game_state.is_inside() else 330

func get_max_distance(camera_origin):
	var dsup = get_camera_limit()
	if not settings.cutoff_enabled:
		return dsup
	var dlim = dsup * DISTANCE_COEFF
	var distances = []
	for view_raycast in get_children():
		if view_raycast.is_colliding():
			var cp = view_raycast.get_collision_point()
			var d = camera_origin.distance_to(cp)
			if d < dlim - MIN_DIFF:
				distances.append(d)
			else:
				return dsup
		else:
			return dsup
	
	if distances.empty():
		return dsup
	
	distances.sort()
	var dmin = distances.pop_front()
	var dmax = dmin
	var diff_cur = 0
	var diff_max = MIN_DIFF
	for d in distances:
		diff_cur = d - dmax
		if diff_cur > diff_max:
			diff_max = diff_cur
			dmax = d

	var result = dmax + diff_max
	
	return result if result <= dlim and result > 0 else dsup
