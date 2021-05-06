extends VisibilityNotifier
class_name PLDRoomEnabler

signal player_entered_room(room_id)
signal player_left_room(room_id)

const REMOVE_FROM_TREE = false

export(DB.RoomIds) var room_id = DB.RoomIds.NONE
export var room_path = "../room"
var raycasts_cache = []
var room_children = []
var screen_entered = false
var player_is_in_room = false
var active = false

func _ready():
	raycasts_cache.clear()
	set_active(false)
	connect("screen_entered", self, "_on_VisibilityEnabler_screen_entered")
	connect("screen_exited", self, "_on_VisibilityEnabler_screen_exited")
	game_state.register_room_enabler(self)

func _on_VisibilityEnabler_screen_entered():
	screen_entered = true

func _on_VisibilityEnabler_screen_exited():
	screen_entered = false
	enable_raycasts(false)

func get_raycasts():
	if not raycasts_cache.empty():
		return raycasts_cache
	var result = []
	for ch in get_children():
		if ch is RayCast:
			result.append(ch)
		for r in ch.get_children():
			if r is RayCast:
				result.append(r)
	raycasts_cache = result
	return result

func enable_raycasts(enable):
	for raycast in get_raycasts():
		raycast.enabled = enable

func get_room_id():
	return room_id

func get_room_node():
	return get_node(room_path)

func is_room_enabled():
	var room_node = get_room_node()
	if REMOVE_FROM_TREE:
		return room_node.get_child_count() > 0
	else:
		return room_node.visible

func player_is_in_room():
	return player_is_in_room

func enable_room():
	var room_node = get_room_node()
	if REMOVE_FROM_TREE:
		if room_node.get_child_count() == 0:
			for ch in room_children:
				room_node.add_child(ch)
			room_children.clear()
	else:
		room_node.visible = true

func disable_room():
	var room_node = get_room_node()
	if REMOVE_FROM_TREE:
		if room_node.get_child_count() > 0:
			var room_children_was_empty = room_children.empty()
			for ch in room_node.get_children():
				room_node.remove_child(ch)
				if room_children_was_empty:
					room_children.append(ch)
	else:
		room_node.visible = false

func set_active(active):
	set_physics_process(active)
	self.active = active
	if not active:
		enable_room()

func _physics_process(delta):
	if not game_state.is_level_ready():
		return
	var player = game_state.get_player()
	if not player:
		enable_raycasts(false)
		enable_room()
		return
	var camera = player.get_cam()
	if not camera:
		enable_raycasts(false)
		enable_room()
		return
	var origin = camera.get_global_transform().origin
	var player_is_in_room_prev = player_is_in_room
	player_is_in_room = get_aabb().has_point(to_local(origin))
	if player_is_in_room and not player_is_in_room_prev:
		emit_signal("player_entered_room", room_id)
	elif player_is_in_room_prev and not player_is_in_room:
		emit_signal("player_left_room", room_id)
	var need_enable = player_is_in_room
	if not active or not player or need_enable:
		enable_raycasts(false)
		enable_room()
		return
	if not screen_entered:
		disable_room()
		return
	for raycast in get_raycasts():
		var notifier = raycast.get_parent()
		var is_on_screen = notifier.is_on_screen()
		var ray_vec = raycast.to_local(origin)
		var is_outside_camera = ray_vec.length() > camera.far
		if raycast.enabled:
			raycast.cast_to = ray_vec
			need_enable = need_enable or (is_on_screen and not raycast.is_colliding())
		raycast.enabled = not is_outside_camera and is_on_screen
	enable_room() if need_enable else disable_room()
