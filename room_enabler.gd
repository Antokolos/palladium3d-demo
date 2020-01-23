extends Spatial

onready var visibility_notifier = $VisibilityEnabler
onready var raycast = $RayCast
var room_node

func _ready():
	visibility_notifier.connect("screen_entered", self, "_on_VisibilityEnabler_screen_entered")
	visibility_notifier.connect("screen_exited", self, "_on_VisibilityEnabler_screen_exited")
	room_node = visibility_notifier.get_child(0)

func _on_VisibilityEnabler_screen_entered():
	raycast.enabled = true

func _on_VisibilityEnabler_screen_exited():
	raycast.enabled = false

func remove_room():
	if visibility_notifier.get_child_count() > 0:
		visibility_notifier.remove_child(room_node)

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
		elif visibility_notifier.get_child_count() == 0:
			visibility_notifier.add_child(room_node)