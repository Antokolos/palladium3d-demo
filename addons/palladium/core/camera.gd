extends Camera
class_name PLDCamera

onready var flashlight = get_node("Flashlight") if has_node("Flashlight") else null
onready var flashlight_spot = flashlight.get_node("Flashlight") if flashlight else null
onready var cutscene_flashlight = get_node("CutsceneFlashlight") if has_node("CutsceneFlashlight") else null
onready var use_point = get_node("Gun_Fire_Points/use_point") if has_node("Gun_Fire_Points/use_point") else null

onready var env_norm = preload("res://addons/palladium/env_norm.tres")
onready var env_opt = preload("res://addons/palladium/env_opt.tres")
onready var env_good = preload("res://addons/palladium/env_good.tres")
onready var env_high = preload("res://addons/palladium/env_high.tres")

onready var culling_rays = get_node("culling_rays") if has_node("culling_rays") else null
onready var shader_cache = get_node("viewpoint/shader_cache") if has_node("viewpoint/shader_cache") else null
onready var item_preview = get_node("viewpoint/item_preview") if has_node("viewpoint/item_preview") else null
onready var item_use = get_node("viewpoint/item_use") if has_node("viewpoint/item_use") else null

func _ready():
	change_quality(settings.quality)
	settings.connect("quality_changed", self, "change_quality")
	game_state.connect("game_loaded", self, "_on_game_loaded")
	if item_preview:
		item_preview.connect("preview_opened", self, "_on_preview_opened")
		item_preview.connect("preview_closed", self, "_on_preview_closed")

func rebuild_exceptions(player_node):
	if use_point:
		use_point.rebuild_exceptions(player_node)

func enable_use(enable):
	if use_point:
		use_point.enable(enable)

func show_cutscene_flashlight(enable):
	cutscene_flashlight.visible = enable
	if enable:
		flashlight.hide()
	elif flashlight and game_state.is_flashlight_on():
		flashlight.show()

func get_use_distance():
	return use_point.get_use_distance() if use_point else 0

# Settings applied in the following way will be loaded after game restart
# see https://github.com/godotengine/godot/issues/30087
#func apply_advanced_settings(force_vertex_shading):
#	var config = ConfigFile.new()
#	config.set_value("rendering", "quality/shading/force_vertex_shading", force_vertex_shading)
#	config.save("user://settings.ini")

func change_quality(quality):
	match quality:
		settings.QUALITY_NORM:
			self.environment = env_norm
			#get_tree().call_group("lightmaps", "enable", false)
			#game_state.get_viewport().shadow_atlas_size = 2048
			get_tree().call_group("fire_sources", "set_quality_normal")
			get_tree().call_group("light_sources", "set_quality_normal")
			get_tree().call_group("grass", "set_quality_normal")
			get_tree().call_group("moving", "shadow_casting_enable", false)
			get_tree().call_group("trees", "wind_effect_enable", false)
			if flashlight_spot:
				flashlight_spot.set("shadow_enabled", false)
			ProjectSettings.set_setting("rendering/quality/shadows/filter_mode", 0)
		settings.QUALITY_OPT:
			self.environment = env_opt
			#get_tree().call_group("lightmaps", "enable", true)
			#game_state.get_viewport().shadow_atlas_size = 2048
			get_tree().call_group("fire_sources", "set_quality_optimal")
			get_tree().call_group("light_sources", "set_quality_optimal")
			get_tree().call_group("grass", "set_quality_optimal")
			get_tree().call_group("moving", "shadow_casting_enable", false)
			get_tree().call_group("trees", "wind_effect_enable", false)
			if flashlight_spot:
				flashlight_spot.set("shadow_enabled", false)
			ProjectSettings.set_setting("rendering/quality/shadows/filter_mode", 0)
		settings.QUALITY_GOOD:
			self.environment = env_good
			#get_tree().call_group("lightmaps", "enable", false)
			#game_state.get_viewport().shadow_atlas_size = 4096
			get_tree().call_group("fire_sources", "set_quality_good")
			get_tree().call_group("light_sources", "set_quality_good")
			get_tree().call_group("grass", "set_quality_good")
			get_tree().call_group("moving", "shadow_casting_enable", false)
			get_tree().call_group("trees", "wind_effect_enable", true)
			if flashlight_spot:
				flashlight_spot.set("shadow_enabled", false)
			ProjectSettings.set_setting("rendering/quality/shadows/filter_mode", 1)
		settings.QUALITY_HIGH:
			self.environment = env_high
			#get_tree().call_group("lightmaps", "enable", false)
			#game_state.get_viewport().shadow_atlas_size = 8192
			get_tree().call_group("fire_sources", "set_quality_high")
			get_tree().call_group("light_sources", "set_quality_high")
			get_tree().call_group("grass", "set_quality_high")
			get_tree().call_group("moving", "shadow_casting_enable", true)
			get_tree().call_group("trees", "wind_effect_enable", true)
			if flashlight_spot:
				flashlight_spot.set("shadow_enabled", true)
			ProjectSettings.set_setting("rendering/quality/shadows/filter_mode", 2)
	set_inside(game_state.is_inside(), game_state.is_bright())
	if shader_cache:
		shader_cache.refresh(settings.shader_cache_enabled)

func _on_game_loaded():
	show_flashlight(game_state.is_flashlight_on())

func set_inside(inside, bright):
	environment.set_background(Environment.BG_COLOR_SKY if inside else Environment.BG_SKY)
	environment.set_bg_color(Color(1, 1, 1) if bright else Color(0, 0, 0))
	environment.set("background_sky", game_state.sky_inside if inside else game_state.sky_outside)
	environment.set("background_energy", 0.3 if bright else (0.04 if inside else 0.25))
	environment.set("background_sky_rotation_degrees", game_state.sky_rotation_degrees)
	environment.set("ambient_light_energy", 0.3 if bright else (0.04 if inside else 0.25))

func change_culling():
	if culling_rays:
		self.far = culling_rays.get_max_distance(self.get_global_transform().origin)

func activate_item_use(item):
	# TODO: eliminate use cases when item_use is null
	if item_use:
		item_use.activate_item(item)

func clear_item_use():
	# TODO: eliminate use cases when item_use is null
	if item_use:
		item_use.clear_item()

func walk_initiate(player_node):
	if item_use:
		item_use.walk_initiate(player_node, self)

func walk_stop(player_node):
	if item_use:
		item_use.walk_stop(player_node, self)

func process_rotation(player_node):
	if item_use:
		item_use.process_rotation(player_node, self)

func show_flashlight(is_show):
	if flashlight:
		if is_show:
			flashlight.show()
		else:
			flashlight.hide()

func _on_preview_opened(item):
	clear_item_use()
	show_cutscene_flashlight(true)

func _on_preview_closed(item):
	show_cutscene_flashlight(false)

func _process(delta):
	if not game_state.is_level_ready():
		return
	# ----------------------------------
	# Turning the flashlight on/off
	if flashlight \
		and not cutscene_flashlight.visible \
		and Input.is_action_just_pressed("flashlight"):
		if flashlight.is_visible_in_tree():
			$AudioStreamFlashlightOff.play()
			flashlight.hide()
			game_state.change_flashlight_state(self, false)
		else:
			$AudioStreamFlashlightOn.play()
			flashlight.show()
			game_state.change_flashlight_state(self, true)
	# ----------------------------------
	
	if use_point:
		var player = game_state.get_player()
		game_state.get_hud().main_hud.get_node("HBoxHints/ActionHintLabel").text = use_point.highlight(player)
	change_culling()

func _input(event):
	if get_tree().paused \
		or conversation_manager.conversation_is_in_progress():
		return
	var player = game_state.get_player()
	if not player or player.is_hidden():
		return
	if item_preview and event.is_action_pressed("item_preview_toggle"):
		if item_preview.is_opened():
			return
		var hud = game_state.get_hud()
		if not hud:
			return
		if hud.is_in_conversation():
			return 
		var item = hud.get_active_item()
		if not item:
			return
		item_preview.open_preview(item)
	elif use_point and item_use and event.is_action_pressed("action"):
		use_point.action(player, self)
		item_use.action(player, self)
		get_tree().set_input_as_handled()
