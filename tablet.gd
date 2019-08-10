extends Control

onready var tablet_panel = get_node("TabletPanel")
onready var home_button = get_node("TabletPanel/HomeButton")
onready var desktop = get_node("TabletPanel/TabletScreen/desktop")
onready var apps = get_node("TabletPanel/TabletScreen/apps")
onready var chat = apps.get_node("chat")
onready var settings_app = apps.get_node("settings_app")
onready var tablet_orientation = settings_app.get_node("VBoxContainer/HTabletOrientation/TabletOrientation")
onready var vsync = settings_app.get_node("VBoxContainer/HVsync/Vsync")
onready var fullscreen = settings_app.get_node("VBoxContainer/HFullscreen/Fullscreen")
onready var quality = settings_app.get_node("VBoxContainer/HQuality/Quality")
onready var resolution = settings_app.get_node("VBoxContainer/HResolution/Resolution")
onready var aa = settings_app.get_node("VBoxContainer/HAA/AA")
onready var language = settings_app.get_node("VBoxContainer/HLanguage/Language")

var available_resolutions = [
Vector2(0, 576),
Vector2(0, 720),
Vector2(0, 1080)
]

onready var hud = get_parent()

func _ready():
	get_tree().get_root().connect("size_changed", self, "on_viewport_resize")

	tablet_orientation.add_item("Vertical", settings.TABLET_VERTICAL)
	tablet_orientation.add_item("Horizontal", settings.TABLET_HORIZONTAL)
	match (settings.tablet_orientation):
		settings.TABLET_VERTICAL:
			tablet_orientation.select(0)
		settings.TABLET_HORIZONTAL:
			tablet_orientation.select(1)
	_on_TabletOrientation_item_selected(settings.tablet_orientation)

	vsync.pressed = settings.vsync
	_on_Vsync_pressed()

	fullscreen.pressed = settings.fullscreen
	_on_Fullscreen_pressed()

	quality.add_item("Normal", settings.QUALITY_NORM)
	quality.add_item("Optimal", settings.QUALITY_OPT)
	quality.add_item("Good", settings.QUALITY_GOOD)
	quality.add_item("High", settings.QUALITY_HIGH)
	match (settings.quality):
		settings.QUALITY_NORM:
			quality.select(0)
		settings.QUALITY_OPT:
			quality.select(1)
		settings.QUALITY_GOOD:
			quality.select(2)
		settings.QUALITY_HIGH:
			quality.select(3)
	# _on_Quality_item_selected(settings.quality) -- not needed here, will be done on player _ready

	var i = 0
	var ssize = OS.get_screen_size()
	for r in available_resolutions:
		resolution.add_item("%d x %d" % [ssize.x * available_resolutions[i].y / ssize.y, available_resolutions[i].y], i)
		i = i + 1
	resolution.add_item("Native (%d x %d)" % [ssize.x, ssize.y], i)
	match (settings.resolution):
		settings.RESOLUTION_480:
			resolution.select(0)
		settings.RESOLUTION_576:
			resolution.select(1)
		settings.RESOLUTION_720:
			resolution.select(2)
		settings.RESOLUTION_1080:
			resolution.select(3)
		_:
			resolution.select(i)
	_on_Resolution_item_selected(settings.resolution)

	aa.add_item("Disabled", settings.AA_DISABLED)
	aa.add_item("2x", settings.AA_2X)
	aa.add_item("4x", settings.AA_4X)
	aa.add_item("8x", settings.AA_8X)
	match (settings.aa_quality):
		settings.AA_DISABLED:
			aa.select(0)
		settings.AA_2X:
			aa.select(1)
		settings.AA_4X:
			aa.select(2)
		settings.AA_8X:
			aa.select(3)
	_on_AA_item_selected(settings.aa_quality)
	
	language.add_item("English", settings.LANGUAGE_EN)
	language.add_item("Russian", settings.LANGUAGE_RU)
	match (settings.language):
		settings.LANGUAGE_EN:
			language.select(0)
		settings.language_RU:
			language.select(1)
		_:
			language.select(0)
	_on_Language_item_selected(settings.language)

func on_viewport_resize():
	# Uncomment the following line to look at the viewport size changes
	#print("Resizing: ", get_viewport_rect().size) # or get_tree().get_root().size
	pass

func _unhandled_input(event):
	if get_tree().paused and event.is_action_pressed("ui_cancel"):
		hud.show_tablet(false)

func _on_HomeButton_pressed():
	for node in apps.get_children():
		node.hide()
	desktop.show()

func _on_ChatButton_pressed():
	desktop.hide()
	chat.show()

func _on_SettingsButton_pressed():
	desktop.hide()
	settings_app.show()

func _on_TabletOrientation_item_selected(ID):
	if ID == settings.TABLET_HORIZONTAL:
		tablet_panel.anchor_left = 0.05
		tablet_panel.anchor_top = 0.05
		tablet_panel.anchor_right = 0.95
		tablet_panel.anchor_bottom = 0.95
		home_button.anchor_left = 1
		home_button.anchor_top = 0.5
		home_button.anchor_right = 1
		home_button.anchor_bottom = 0.5
		home_button.margin_left = -40
		home_button.margin_top = -20
		home_button.margin_right = 0
		home_button.margin_bottom = 20
	else:
		tablet_panel.anchor_left = 0.32
		tablet_panel.anchor_top = 0.01
		tablet_panel.anchor_right = 0.68
		tablet_panel.anchor_bottom = 0.99
		home_button.anchor_left = 0.5
		home_button.anchor_top = 1
		home_button.anchor_right = 0.5
		home_button.anchor_bottom = 1
		home_button.margin_left = -20
		home_button.margin_top = -40
		home_button.margin_right = 20
		home_button.margin_bottom = 0
	tablet_panel.margin_left = 0
	tablet_panel.margin_top = 0
	tablet_panel.margin_right = 0
	tablet_panel.margin_bottom = 0
	tablet_panel.update()
	home_button.update()
	settings.tablet_orientation = ID

func _on_Vsync_pressed():
	var vs = vsync.is_pressed() if vsync else settings.vsync
	OS.set_use_vsync(vs)
	settings.vsync = vs

func _on_Fullscreen_pressed():
	var fs = fullscreen.is_pressed() if fullscreen else settings.fullscreen
	OS.set_window_fullscreen(fs)
	settings.fullscreen = fs

func _on_Quality_item_selected(ID):
	var camera = get_node("../../../Rotation_Helper/Camera/camera")
	if camera:
		camera.change_quality(ID)
	settings.quality = ID

func _on_Resolution_item_selected(ID):
	if ID >= available_resolutions.size():
		var ssize = OS.get_screen_size()
		get_tree().get_root().set_size_override(true, ssize)
		get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_VIEWPORT, SceneTree.STRETCH_ASPECT_KEEP, ssize)
	else:
		var minsize=Vector2( OS.window_size.x * available_resolutions[ID].y / OS.window_size.y, available_resolutions[ID].y)
		get_tree().get_root().set_size_override(true, minsize)
		get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_VIEWPORT, SceneTree.STRETCH_ASPECT_KEEP_HEIGHT, minsize)
	settings.resolution = ID

func _on_AA_item_selected(ID):
	if (ID == settings.AA_8X):
		get_node("/root").msaa = Viewport.MSAA_8X
	elif (ID == settings.AA_4X):
		get_node("/root").msaa = Viewport.MSAA_4X
	elif (ID == settings.AA_2X):
		get_node("/root").msaa = Viewport.MSAA_2X
	else:
		get_node("/root").msaa = Viewport.MSAA_DISABLED
	settings.aa_quality = ID

func _on_Language_item_selected(ID):
	settings.language = ID
