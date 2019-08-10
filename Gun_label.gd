extends Label

onready var camera = get_node("../../../../Rotation_Helper/Camera/camera")

func _physics_process(delta):
	var stats = [
	"FPS: %d" % Performance.get_monitor(Performance.TIME_FPS),
	"\n Render objects: %d" % Performance.get_monitor(Performance.RENDER_OBJECTS_IN_FRAME),
	"\n Material changes: %d" % Performance.get_monitor(Performance.RENDER_MATERIAL_CHANGES_IN_FRAME),
	"\n Shader changes: %d" % Performance.get_monitor(Performance.RENDER_SHADER_CHANGES_IN_FRAME),
	"\n Surface changes: %d" % Performance.get_monitor(Performance.RENDER_SURFACE_CHANGES_IN_FRAME),
	"\n Drawcalls: %d" % Performance.get_monitor(Performance.RENDER_DRAW_CALLS_IN_FRAME),
	"\n Camera Far: %f" % camera.far
	]
	text = ""
	for stat in stats:
		text = text + stat

