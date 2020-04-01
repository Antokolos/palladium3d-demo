extends Label

func _physics_process(delta):
	var camera = game_params.get_player().get_cam()
	var stats = [
	"FPS: %d" % Performance.get_monitor(Performance.TIME_FPS),
	"\nRender objects: %d" % Performance.get_monitor(Performance.RENDER_OBJECTS_IN_FRAME),
	"\nMaterial changes: %d" % Performance.get_monitor(Performance.RENDER_MATERIAL_CHANGES_IN_FRAME),
	"\nShader changes: %d" % Performance.get_monitor(Performance.RENDER_SHADER_CHANGES_IN_FRAME),
	"\nSurface changes: %d" % Performance.get_monitor(Performance.RENDER_SURFACE_CHANGES_IN_FRAME),
	"\nDrawcalls: %d" % Performance.get_monitor(Performance.RENDER_DRAW_CALLS_IN_FRAME),
	"\nCamera Far: %f" % camera.far if camera else ""
	]
	text = ""
	for stat in stats:
		text = text + stat

