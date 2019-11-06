extends Spatial

export var width = 3.0
export var height = 2.0
export var quality = 0.3
export var cam_shift = 0.0
export var cam_fov = 45
export var cam_far = 18.2
export var cam_coeff_1 = 700
export var cam_coeff_2 = 0.85
export var activator_add = 1.6
export var activator_depth = 10.7

var is_mirror = true
var active = false

onready var mirror_plane = get_node('MirrorPlane')
onready var viewport = get_node('Viewport')
onready var camera = get_node('Viewport/Camera')
onready var activation_shape = get_node('Area/CollisionShape')

func _ready():
	# The following line is not needed, see https://github.com/godotengine/godot/issues/23750#issuecomment-440708856
	#mirror_plane.material_override.albedo_texture = viewport.get_texture()
	mirror_plane.mesh.size = Vector2(width, height)
	activation_shape.shape.extents = Vector3(width / 2.0 + activator_add, height / 2.0 + activator_add, activator_depth)
	get_tree().get_root().connect("size_changed", self, "_on_resolution_changed")
	_on_resolution_changed()

func _on_resolution_changed():
	var screen_size = get_tree().get_root().size
	var pixels_size = screen_size.y * quality
	viewport.size = Vector2(int(width * pixels_size), int(height * pixels_size))

func _process(delta):
	if active:
		var player = game_params.get_player()
		persp(player)

func persp(player):
	if not player:
		return
	var eyes = player.get_cam_holder().get_child(0)
	var viewpoint = eyes.get_node("viewpoint")
	var cam_pos = mirror_plane.get_global_transform().origin
	var init = cam_pos
	var player_pos = eyes.get_global_transform().origin
	var viewpoint_pos = viewpoint.get_global_transform().origin
	#viewpoint_pos.y = player_pos.y
	var los = viewpoint_pos - player_pos
	var reflected_los = los.bounce(Vector3(0,0,1))
	cam_pos.y = cam_pos.y + cam_shift
	var target_pos = cam_pos + cam_coeff_1 * reflected_los
	cam_pos.x = cam_pos.x + (player_pos.x - cam_pos.x) * cam_coeff_2
	var d = width / 2.0
	if cam_pos.x < init.x - d:
		cam_pos.x = init.x - d
	if cam_pos.x > init.x + d:
		cam_pos.x = init.x + d
	camera.look_at_from_position(cam_pos, target_pos, Vector3(0,1,0))

func ortho(player):
	if not player:
		return
	var eyes = player.get_cam_holder().get_child(0)
	var viewpoint = eyes.get_node("viewpoint")
	var cam_pos = to_global(mirror_plane.get_translation())
	var player_pos = to_global(player.get_translation())
	camera.v_offset = cam_pos.y - player_pos.y
	cam_pos.y = player_pos.y
	var sgn = -1.0 if (player_pos.x - cam_pos.x) < 0.0 else 1.0
	var d1 = cam_pos.distance_squared_to(player_pos)
	cam_pos.x = player_pos.x
	var z = player_pos.z
	player_pos = cam_pos
	player_pos.z = z
	var d2 = cam_pos.distance_squared_to(player_pos)
	camera.size = cam_pos.distance_to(player_pos)
	camera.h_offset = sgn * sqrt(d1 - d2)
	camera.look_at_from_position(cam_pos, player_pos, Vector3(0,1,0))

func activate():
	active = true
	camera.fov = cam_fov
	camera.far = cam_far
	$Viewport.render_target_update_mode = Viewport.UPDATE_WHEN_VISIBLE

func deactivate():
	active = false
	camera.fov = cam_fov
	camera.far = 0.1
	$Viewport.render_target_update_mode = Viewport.UPDATE_ONCE

func _on_Area_body_entered(body):
	if active:
		return
	var player = game_params.get_player()
	if body == player:
		activate()

func _on_Area_body_exited(body):
	if not active:
		return
	var player = game_params.get_player()
	if body == player:
		deactivate()