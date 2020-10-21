extends Label

func _physics_process(delta):
	if not settings.performance_stats:
		visible = false
		return
	var player = game_state.get_player()
	if not player:
		visible = false
		return
	var camera = player.get_cam()
	if not camera:
		visible = false
		return
	visible = true
	var viewport = game_state.get_viewport()
	var viewport_size = viewport.size if viewport else Vector2(0, 0)
	var stats = [
	"FPS: %d" % Performance.get_monitor(Performance.TIME_FPS),
	"\nRender objects: %d" % Performance.get_monitor(Performance.RENDER_OBJECTS_IN_FRAME),
	"\nMaterial changes: %d" % Performance.get_monitor(Performance.RENDER_MATERIAL_CHANGES_IN_FRAME),
	"\nShader changes: %d" % Performance.get_monitor(Performance.RENDER_SHADER_CHANGES_IN_FRAME),
	"\nSurface changes: %d" % Performance.get_monitor(Performance.RENDER_SURFACE_CHANGES_IN_FRAME),
	"\nDrawcalls: %d" % Performance.get_monitor(Performance.RENDER_DRAW_CALLS_IN_FRAME),
	"\nCutoff enabled: %s" % ("true" if settings.cutoff_enabled else "false"),
	"\nCamera Far: %f" % camera.far if camera else "",
	"\nViewport size: %dx%d" % [viewport_size.x, viewport_size.y]
	]
	text = ""
	for stat in stats:
		text = text + stat