extends Label

const COUNT_TORCHES = false

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
	var active_torches = 0
	var inactive_torches = 0
	if COUNT_TORCHES:
		for t in get_tree().get_nodes_in_group("torches"):
			if t.is_visible_in_tree():
				active_torches = active_torches + 1
			else:
				inactive_torches = inactive_torches + 1
	var stats = [
	"FPS: %d" % Performance.get_monitor(Performance.TIME_FPS),
	"\nRender objects: %d" % Performance.get_monitor(Performance.RENDER_OBJECTS_IN_FRAME),
	"\nMaterial changes: %d" % Performance.get_monitor(Performance.RENDER_MATERIAL_CHANGES_IN_FRAME),
	"\nShader changes: %d" % Performance.get_monitor(Performance.RENDER_SHADER_CHANGES_IN_FRAME),
	"\nSurface changes: %d" % Performance.get_monitor(Performance.RENDER_SURFACE_CHANGES_IN_FRAME),
	"\nDrawcalls: %d" % Performance.get_monitor(Performance.RENDER_DRAW_CALLS_IN_FRAME),
	"\nTorches active: %d" % active_torches,
	"\nTorches inactive: %d" % inactive_torches,
	"\nCutoff enabled: %s" % ("true" if settings.cutoff_enabled else "false"),
	"\nCamera Far: %f" % camera.far if camera else "",
	"\nViewport size: %dx%d" % [viewport_size.x, viewport_size.y]
	]
	text = ""
	for stat in stats:
		text = text + stat