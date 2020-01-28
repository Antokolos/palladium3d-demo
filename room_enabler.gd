extends Spatial
class_name RoomEnabler

const REMOVE_FROM_TREE = false

onready var visibility_notifier = $VisibilityEnabler
onready var raycast = $RayCast
onready var room_node = visibility_notifier.get_child(0)

func _ready():
	visibility_notifier.connect("screen_entered", self, "_on_VisibilityEnabler_screen_entered")
	visibility_notifier.connect("screen_exited", self, "_on_VisibilityEnabler_screen_exited")

func _on_VisibilityEnabler_screen_entered():
	raycast.enabled = true

func _on_VisibilityEnabler_screen_exited():
	raycast.enabled = false

func add_room():
	if REMOVE_FROM_TREE:
		if visibility_notifier.get_child_count() == 0:
			visibility_notifier.add_child(room_node)
	else:
		room_node.visible = true

func remove_room():
	if REMOVE_FROM_TREE:
		if visibility_notifier.get_child_count() > 0:
			visibility_notifier.remove_child(room_node)
	else:
		room_node.visible = false

func _physics_process(delta):
	if not raycast.enabled:
		remove_room()
		return
	var player = game_params.get_player()
	if player:
		var camera = player.get_cam()
		var origin = camera.get_global_transform().origin
		raycast.cast_to = raycast.to_local(origin)
		if raycast.is_colliding():
			remove_room()
		else:
			add_room()
