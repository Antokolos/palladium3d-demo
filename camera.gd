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

func _ready():
	change_quality(settings.quality)

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
			get_tree().call_group("moving", "shadow_casting_enable", false)
			flashlight.set("shadow_enabled", false)
			ProjectSettings.set_setting("rendering/quality/shadows/filter_mode", 0)
		settings.QUALITY_OPT:
			self.environment = env_opt
			#get_tree().call_group("lightmaps", "enable", true)
			#get_viewport().shadow_atlas_size = 2048
			get_tree().call_group("fire_sources", "set_quality_optimal")
			get_tree().call_group("light_sources", "set_quality_optimal")
			get_tree().call_group("moving", "shadow_casting_enable", false)
			flashlight.set("shadow_enabled", false)
			ProjectSettings.set_setting("rendering/quality/shadows/filter_mode", 1)
		settings.QUALITY_GOOD:
			self.environment = env_good
			#get_tree().call_group("lightmaps", "enable", false)
			#get_viewport().shadow_atlas_size = 4096
			get_tree().call_group("fire_sources", "set_quality_good")
			get_tree().call_group("light_sources", "set_quality_good")
			get_tree().call_group("moving", "shadow_casting_enable", false)
			flashlight.set("shadow_enabled", false)
			ProjectSettings.set_setting("rendering/quality/shadows/filter_mode", 1)
		settings.QUALITY_HIGH:
			self.environment = env_high
			#get_tree().call_group("lightmaps", "enable", false)
			#get_viewport().shadow_atlas_size = 8192
			get_tree().call_group("fire_sources", "set_quality_high")
			get_tree().call_group("light_sources", "set_quality_high")
			get_tree().call_group("moving", "shadow_casting_enable", true)
			flashlight.set("shadow_enabled", true)
			ProjectSettings.set_setting("rendering/quality/shadows/filter_mode", 2)
	shader_cache.refresh()

func change_culling():
	self.far = culling_rays.get_max_distance(self.get_global_transform().origin)

func _process(delta):
	# ----------------------------------
	# Turning the flashlight on/off
	if Input.is_action_just_pressed("flashlight"):
		if flashlight.is_visible_in_tree():
			flashlight.hide()
		else:
			flashlight.show()
	# ----------------------------------
	
	var player = get_node("../../..")
	use_point.highlight(player)
	change_culling()

func _input(event):
	if event.is_action_pressed("action"):
		var player = get_node("../../..")
		use_point.action(player)

func _unhandled_input(event):
	var is_key = event is InputEventKey and event.is_pressed()
	if not is_key:
		return
	var hud = get_node("../../..").get_hud()
	if hud.inventory.visible:
		if event.scancode != KEY_Q:
			return
		var item = hud.get_active_item()
		item_preview.open_preview(item, hud, flashlight)