extends VisibilityNotifier
class_name RoomEnabler

export var room_path = "../room"
onready var room_node = get_node(room_path)
var screen_entered = false

func _ready():
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

func enable_room():
	room_node.visible = true

func disable_room():
	room_node.visible = false

func _physics_process(delta):
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
