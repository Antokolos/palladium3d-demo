extends ViewportContainer

onready var camera = $Viewport/Camera
onready var dimmer = $dimmer

func set_camera_environment(environment):
	camera.environment = environment

func show_dimmer(is_show):
	dimmer.visible = is_show

func _process(delta):
	camera.global_transform = get_parent().get_global_transform()