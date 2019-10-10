extends Spatial

const CAMERA_FOV_DEGREES = 55
const STEPS = 4

#const WIDTH_LIMIT = 12
#const HEIGHT_LIMIT = 12
#const STEP = 4

const MIN_DIFF = 0.2
const CUTOFF_ENABLE = false

func create_raycast(x, y, z):
	var r = RayCast.new()
	r.enabled = true
	r.set_collision_mask_bit(0, false)
	r.set_collision_mask_bit(1, true)
	r.cast_to = Vector3(x, y, z)
	return r

#func add_raycast(x, y, z):
#	add_child(create_raycast(x, y, z))
#	add_child(create_raycast(x + STEP2, y, z))
#	add_child(create_raycast(x - STEP2, y, z))
#	add_child(create_raycast(x + STEP2, y + STEP2, z))
#	add_child(create_raycast(x - STEP2, y + STEP2, z))
#	add_child(create_raycast(x + STEP2, y - STEP2, z))
#	add_child(create_raycast(x - STEP2, y - STEP2, z))
#	add_child(create_raycast(x, y + STEP2, z))
#	add_child(create_raycast(x, y - STEP2, z))

func add_raycast(x, y, z):
	add_child(create_raycast(x, y, z))

func _ready():
	init3()

func get_length_limit():
	return get_camera_limit()

func init():
	var width_limit = get_length_limit() * tan(deg2rad(CAMERA_FOV_DEGREES / 2.0))
	var height_limit = width_limit
	var xstep = width_limit / STEPS
	var x = xstep
	var z = -get_length_limit()
	while x <= width_limit + 2 * xstep:
		var ystep = height_limit / STEPS
		var y = ystep
		add_raycast(x, 0, z)
		add_raycast(-x, 0, z)
		while y <= height_limit + 2 * ystep:
			add_raycast(x, y, z)
			add_raycast(-x, y, z)
			add_raycast(x, -y, z)
			add_raycast(-x, -y, z)
			add_raycast(0, -y, z)
			add_raycast(0, y, z)
			y = y + ystep
		x = x + xstep

func init2():
	var z = -get_length_limit()
	var width_limit = get_length_limit() * tan(deg2rad(CAMERA_FOV_DEGREES / 2.0))
	var height_limit = width_limit
	var xstep = width_limit / STEPS
	var x = xstep
	while x <= width_limit + 2 * xstep:
		add_raycast(x, 0, z)
		add_raycast(-x, 0, z)
		add_raycast(x, height_limit, z)
		add_raycast(-x, height_limit, z)
		add_raycast(x, -height_limit, z)
		add_raycast(-x, -height_limit, z)
		x = x + xstep
	
	var ystep = height_limit / STEPS
	var y = ystep
	while y <= height_limit + 2 * ystep:
		add_raycast(0, y, z)
		add_raycast(0, -y, z)
		add_raycast(width_limit, y, z)
		add_raycast(width_limit, -y, z)
		add_raycast(-width_limit, y, z)
		add_raycast(-width_limit, -y, z)
		y = y + ystep

func init3():
	var z = -get_length_limit()
	var width_limit = get_length_limit() * tan(deg2rad(CAMERA_FOV_DEGREES / 2.0))
	var height_limit = width_limit
	var xstep = width_limit / STEPS
	var x = xstep
	while x <= width_limit + xstep:
		add_raycast(x, 0, z)
		add_raycast(-x, 0, z)
		add_raycast(x, x, z)
		add_raycast(-x, x, z)
		add_raycast(x, -x, z)
		add_raycast(-x, -x, z)
		x = x + xstep
	
	var ystep = height_limit / STEPS
	var y = ystep
	while y <= height_limit + ystep:
		add_raycast(0, y, z)
		add_raycast(0, -y, z)
		y = y + ystep

func get_camera_limit():
	return 50 if game_params.is_inside() else 330

func get_max_distance(camera_origin):
	var dsup = get_camera_limit()
	if not CUTOFF_ENABLE:
		return dsup
	var distances = []
	for view_raycast in get_children():
		if view_raycast.is_colliding():
			var cp = view_raycast.get_collision_point()
			var d = camera_origin.distance_to(cp)
			if d < dsup - MIN_DIFF:
				distances.append(d)
#				var different = true
#				for dist in distances:
#					if d < dist + MIN_DIFF and d > dist - MIN_DIFF:
#						different = false
#						break
#				if different:
#					distances.append(d)
	
	if distances.empty():
		return dsup
	
	distances.sort()
	var dmin = distances.pop_front()
	var dprev = dmin
	var differents = 1
	for d in distances:
		if d > dprev + MIN_DIFF:
			differents = differents + 1
			dprev = d
	var dmax = dprev
	
	if differents == 1:
		return dmax + MIN_DIFF
	
	var diff = (dmax - dmin) / (differents - 1)
	var result = dmax + diff + MIN_DIFF
	
	return result if result <= dsup and result > 0 else dsup

#func get_max_distance2(camera_origin):
#	var dsup = CAMERA_LIMIT
#	var distances = []
#	for view_raycast in get_children():
#		if view_raycast is RayCast and view_raycast.is_colliding():
#			var cp = view_raycast.get_collision_point()
#			var d = camera_origin.distance_to(cp)
#			if d < dsup - MIN_DIFF:
#				distances.append(d)
#	
#	distances.sort()
#	if distances.empty():
#		return dsup
#	
#	var diff_max = 0
#	var dprev = distances.pop_front()
#	var ddiff = dprev
#	for d in distances:
#		var diff = d - ddiff
#		if diff > diff_max and diff > MIN_DIFF:
#			diff_max = diff
#			ddiff = d
#		dprev = d
#	var dmax = dprev + diff_max
#	
#	return dmax if dmax <= dsup and dmax > 0 else dsup

#func _physics_process(delta):
#	if rot >= ROT_MAX:
#		rot_dir = -1
#	elif rot <= -ROT_MAX:
#		rot_dir = 1
#		dmax = 0
#	rot = rot + rot_dir * ROT_STEP
#	rotate_y(rot_dir * ROT_STEP)