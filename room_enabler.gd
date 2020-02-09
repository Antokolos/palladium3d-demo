extends VisibilityNotifier
class_name RoomEnabler

const REMOVE_FROM_TREE = true

export var room_path = "../room"
var room_children = []
var screen_entered = false
var active = false

func _ready():
	set_active(false)
	connect("screen_entered", self, "_on_VisibilityEnabler_screen_entered")
	connect("screen_exited", self, "_on_VisibilityEnabler_screen_exited")

func _on_VisibilityEnabler_screen_entered():
	for raycast in get_children():
		raycast.enabled = true
	screen_entered = true

func _on_VisibilityEnabler_screen_exited():
	for raycast in get_children():
		raycast.enabled = false
	screen_entered = false

func get_room_node():
	return get_node(room_path)

func enable_room():
	var room_node = get_room_node()
	if REMOVE_FROM_TREE:
		if room_node.get_child_count() == 0:
			for ch in room_children:
				room_node.add_child(ch)
	else:
		room_node.visible = true

func disable_room():
	var room_node = get_room_node()
	if REMOVE_FROM_TREE:
		if room_node.get_child_count() > 0:
			var room_children_was_empty = room_children.empty()
			for ch in room_node.get_children():
				if room_children_was_empty:
					room_children.append(ch)
				room_node.remove_child(ch)
	else:
		room_node.visible = false

func set_active(active):
	set_physics_process(active)
	self.active = active
	if not active:
		enable_room()

func _physics_process(delta):
	if not active:
		enable_room()
		return
	if not screen_entered:
		disable_room()
		return
	var player = game_params.get_player()
	if player:
		var camera = player.get_cam()
		var origin = camera.get_global_transform().origin
		var need_enable = get_aabb().has_point(to_local(origin))
		for raycast in get_children():
			raycast.cast_to = raycast.to_local(origin)
			need_enable = need_enable or not raycast.is_colliding()
		if need_enable:
			enable_room()
		else:
			disable_room()
