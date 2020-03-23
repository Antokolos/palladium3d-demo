extends Camera

onready var flashlight = get_node("Flashlight")
onready var use_point = get_node("Gun_Fire_Points/Use_Point")

onready var env_norm = preload("res://env_norm.tres")
onready var env_opt = preload("res://env_opt.tres")
onready var env_good = preload("res://env_good.tres")
onready var env_high = preload("res://env_high.tres")

onready var culling_rays = get_node("culling_rays")
onready var shader_cache = get_node("viewpoint/shader_cache")
onready var item_preview = get_node("viewpoint/item_preview")

var sky_outside
var sky_inside

func _ready():
	sky_outside = PanoramaSky.new()
	sky_outside.panorama = load("res://assets/cape_hill_4k.hdr")
	sky_outside.radiance_size = Sky.RADIANCE_SIZE_32
	sky_inside = PanoramaSky.new()
	sky_inside.panorama = load("res://assets/ui/undersky5.png")
	sky_inside.radiance_size = Sky.RADIANCE_SIZE_32
	change_quality(settings.quality)
	settings.connect("quality_changed", self, "change_quality")

func enable_use(enable):
	use_point.enable(enable)

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
			#get_viewport().shadow_atlas_size = 2048
			get_tree().call_group("fire_sources", "set_quality_normal")
			get_tree().call_group("light_sources", "set_quality_normal")
			get_tree().call_group("grass", "set_quality_normal")
			get_tree().call_group("moving", "shadow_casting_enable", false)
			get_tree().call_group("trees", "wind_effect_enable", false)
			if flashlight:
				flashlight.set("shadow_enabled", false)
			ProjectSettings.set_setting("rendering/quality/shadows/filter_mode", 0)
		settings.QUALITY_OPT:
			self.environment = env_opt
			#get_tree().call_group("lightmaps", "enable", true)
			#get_viewport().shadow_atlas_size = 2048
			get_tree().call_group("fire_sources", "set_quality_optimal")
			get_tree().call_group("light_sources", "set_quality_optimal")
			get_tree().call_group("grass", "set_quality_optimal")
			get_tree().call_group("moving", "shadow_casting_enable", false)
			get_tree().call_group("trees", "wind_effect_enable", false)
			if flashlight:
				flashlight.set("shadow_enabled", false)
			ProjectSettings.set_setting("rendering/quality/shadows/filter_mode", 0)
		settings.QUALITY_GOOD:
			self.environment = env_good
			#get_tree().call_group("lightmaps", "enable", false)
			#get_viewport().shadow_atlas_size = 4096
			get_tree().call_group("fire_sources", "set_quality_good")
			get_tree().call_group("light_sources", "set_quality_good")
			get_tree().call_group("grass", "set_quality_good")
			get_tree().call_group("moving", "shadow_casting_enable", false)
			get_tree().call_group("trees", "wind_effect_enable", true)
			if flashlight:
				flashlight.set("shadow_enabled", false)
			ProjectSettings.set_setting("rendering/quality/shadows/filter_mode", 1)
		settings.QUALITY_HIGH:
			self.environment = env_high
			#get_tree().call_group("lightmaps", "enable", false)
			#get_viewport().shadow_atlas_size = 8192
			get_tree().call_group("fire_sources", "set_quality_high")
			get_tree().call_group("light_sources", "set_quality_high")
			get_tree().call_group("grass", "set_quality_high")
			get_tree().call_group("moving", "shadow_casting_enable", true)
			get_tree().call_group("trees", "wind_effect_enable", true)
			if flashlight:
				flashlight.set("shadow_enabled", true)
			ProjectSettings.set_setting("rendering/quality/shadows/filter_mode", 2)
	set_inside(game_params.is_inside())
	if shader_cache:
		shader_cache.refresh()

func set_inside(inside):
	environment.set_background(Environment.BG_COLOR_SKY if inside else Environment.BG_SKY)
	environment.set_bg_color(Color(0, 0, 0))
	environment.set("background_sky", sky_inside if inside else sky_outside)
	environment.set("background_energy", 0.04 if inside else 0.4)
	environment.set("ambient_light_energy", 0.04 if inside else 0.4)

func change_culling():
	if culling_rays:
		self.far = culling_rays.get_max_distance(self.get_global_transform().origin)

func restore_state():
	if game_params.story_vars.flashlight_on:
		flashlight.show()

func _process(delta):
	# ----------------------------------
	# Turning the flashlight on/off
	if flashlight and Input.is_action_just_pressed("flashlight"):
		if flashlight.is_visible_in_tree():
			$AudioStreamFlashlightOff.play()
			flashlight.hide()
			game_params.story_vars.flashlight_on = false
		else:
			$AudioStreamFlashlightOn.play()
			flashlight.show()
			game_params.story_vars.flashlight_on = true
	# ----------------------------------
	
	if use_point:
		var player = game_params.get_player()
		use_point.highlight(player)
	change_culling()

func _input(event):
	if event.is_action_pressed("action"):
		var player = game_params.get_player()
		if player:
			use_point.action(player)

func _unhandled_input(event):
	var is_key = event is InputEventKey and event.is_pressed()
	if not is_key:
		return
	var player = game_params.get_player()
	if not player:
		return
	var hud = player.get_hud()
	if hud and not item_preview.is_opened():
		if event.scancode != KEY_Q:
			return
		var item = hud.get_active_item()
		if item:
			item_preview.open_preview(item, hud, flashlight)
