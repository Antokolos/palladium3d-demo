extends Control

onready var tablet_panel = get_node("TabletPanel")
onready var home_button = get_node("TabletPanel/HomeButton")
onready var desktop = get_node("TabletPanel/TabletScreen/desktop")
onready var apps = get_node("TabletPanel/TabletScreen/apps")
onready var chat = apps.get_node("chat")
onready var settings_app = apps.get_node("settings_app")
onready var save_game_app = apps.get_node("save_game_app")
onready var load_game_app = apps.get_node("load_game_app")
onready var tablet_orientation = settings_app.get_node("VBoxContainer/HTabletOrientation/TabletOrientation")
onready var vsync = settings_app.get_node("VBoxContainer/HVsync/Vsync")
onready var fullscreen = settings_app.get_node("VBoxContainer/HFullscreen/Fullscreen")
onready var quality = settings_app.get_node("VBoxContainer/HQuality/Quality")
onready var resolution = settings_app.get_node("VBoxContainer/HResolution/Resolution")
onready var aa = settings_app.get_node("VBoxContainer/HAA/AA")
onready var language = settings_app.get_node("VBoxContainer/HLanguage/Language")
onready var vlanguage = settings_app.get_node("VBoxContainer/HVLanguage/VLanguage")
onready var master_volume_node = settings_app.get_node("VBoxContainer/HMasterVolume/MasterVolume")
onready var music_volume_node = settings_app.get_node("VBoxContainer/HMusicVolume/MusicVolume")
onready var sound_volume_node = settings_app.get_node("VBoxContainer/HSoundVolume/SoundVolume")
onready var speech_volume_node = settings_app.get_node("VBoxContainer/HSpeechVolume/SpeechVolume")

var available_resolutions = [
{
	"resolution_height" : 576,
	"default_font" : 14,
	"text_separation" : 3,
	"actorname_prev_font" : 10,
	"conversation_prev_font" : 10,
	"actorname_font" : 16,
	"conversation_font" : 16
},
{
	"resolution_height" : 720,
	"default_font" : 18,
	"text_separation" : 10,
	"actorname_prev_font" : 14,
	"conversation_prev_font" : 14,
	"actorname_font" : 20,
	"conversation_font" : 20
},
{
	"resolution_height" : 1080,
	"default_font" : 26,
	"text_separation" : 30,
	"actorname_prev_font" : 20,
	"conversation_prev_font" : 20,
	"actorname_font" : 30,
	"conversation_font" : 30
}
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
		resolution.add_item("%d x %d" % [ssize.x * available_resolutions[i].resolution_height / ssize.y, available_resolutions[i].resolution_height], i)
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
		settings.LANGUAGE_RU:
			language.select(1)
		_:
			language.select(0)
	_on_Language_item_selected(settings.language)
	
	vlanguage.add_item("None", settings.VLANGUAGE_NONE)
	vlanguage.add_item("Russian", settings.VLANGUAGE_RU)
	match (settings.vlanguage):
		settings.VLANGUAGE_NONE:
			vlanguage.select(0)
		settings.VLANGUAGE_RU:
			vlanguage.select(1)
		_:
			language.select(0)
	_on_VLanguage_item_selected(settings.vlanguage)
	
	master_volume_node.value = settings.master_volume
	music_volume_node.value = settings.music_volume
	sound_volume_node.value = settings.sound_volume
	speech_volume_node.value = settings.speech_volume

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
	chat.load_chat()
	chat.show()

func _on_SettingsButton_pressed():
	desktop.hide()
	settings_app.show()

func refresh_slot_captions(base_node):
	for i in range(1, 6):
		var node = base_node.get_node("VBoxContainer/Slot%d/ButtonSlot%d" % [i, i])
		var caption = StoryNode.GetSlotCaption(i)
		node.text = caption if caption.length() > 0 else tr("TABLET_EMPTY_SLOT")

func _on_SaveGameButton_pressed():
	desktop.hide()
	save_game_app.show()
	refresh_slot_captions(save_game_app)

func _on_LoadGameButton_pressed():
	desktop.hide()
	load_game_app.show()
	refresh_slot_captions(load_game_app)

func _on_QuitGameButton_pressed():
	var hud = get_parent() # Can also be accessed via player node
	hud.ask_quit()

func simulate_esc():
	# Why we need such workarounds?
	# Why not just call hud.show_tablet(false) and set mouse mode to Input.MOUSE_MODE_CAPTURED?
	# Well, I tried, but I failed, for some reason it didn't work for me and I don't know why.
	# If you'll simplify this code, please tell me, what am I doing wrong :(
	var ev = InputEventAction.new()
	ev.set_action("ui_cancel")
	ev.set_pressed(true)
	get_tree().input_event(ev)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func save_to_slot(slot):
	StoryNode.SaveAll(slot)
	game_params.save_params(slot)
	simulate_esc()

func load_from_slot(slot):
	game_params.initiate_load(slot)
	simulate_esc()

func _on_ButtonSaveSlot1_pressed():
	save_to_slot(1)

func _on_ButtonSaveSlot2_pressed():
	save_to_slot(2)

func _on_ButtonSaveSlot3_pressed():
	save_to_slot(3)

func _on_ButtonSaveSlot4_pressed():
	save_to_slot(4)

func _on_ButtonSaveSlot5_pressed():
	save_to_slot(5)

func _on_ButtonLoadSlot1_pressed():
	load_from_slot(1)

func _on_ButtonLoadSlot2_pressed():
	load_from_slot(2)

func _on_ButtonLoadSlot3_pressed():
	load_from_slot(3)

func _on_ButtonLoadSlot4_pressed():
	load_from_slot(4)

func _on_ButtonLoadSlot5_pressed():
	load_from_slot(5)

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
	var camera = get_node("../../..").get_cam()
	if camera:
		camera.change_quality(ID)
	settings.quality = ID

func _on_Resolution_item_selected(ID):
	var default_font = hud.get_theme().get_default_font()
	var conversation_root = hud.get_conversation_root()
	var actorname_prev_font = hud.get_actorname_prev().get("custom_fonts/font")
	var conversation_prev_font = hud.get_conversation_text_prev().get("custom_fonts/font")
	var actorname_font = hud.get_actorname().get("custom_fonts/font")
	var conversation_font = hud.get_conversation_text().get("custom_fonts/font")
	var maxid = available_resolutions.size() - 1
	if ID > maxid:
		var ssize = OS.get_screen_size()
		get_tree().get_root().set_size_override(true, ssize)
		get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_VIEWPORT, SceneTree.STRETCH_ASPECT_KEEP, ssize)
		# TODO: maybe upscale font size for native resolution?
		default_font.set_size(available_resolutions[maxid].default_font)
		actorname_prev_font.set_size(available_resolutions[maxid].actorname_prev_font)
		conversation_prev_font.set_size(available_resolutions[maxid].conversation_prev_font)
		actorname_font.set_size(available_resolutions[maxid].actorname_font)
		conversation_font.set_size(available_resolutions[maxid].conversation_font)
		conversation_root.set("custom_constants/separation", available_resolutions[maxid].text_separation)
	else:
		var minsize=Vector2( OS.window_size.x * available_resolutions[ID].resolution_height / OS.window_size.y, available_resolutions[ID].resolution_height)
		get_tree().get_root().set_size_override(true, minsize)
		get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_VIEWPORT, SceneTree.STRETCH_ASPECT_KEEP_HEIGHT, minsize)
		default_font.set_size(available_resolutions[ID].default_font)
		actorname_prev_font.set_size(available_resolutions[ID].actorname_prev_font)
		conversation_prev_font.set_size(available_resolutions[ID].conversation_prev_font)
		actorname_font.set_size(available_resolutions[ID].actorname_font)
		conversation_font.set_size(available_resolutions[ID].conversation_font)
		conversation_root.set("custom_constants/separation", available_resolutions[ID].text_separation)
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
	match ID:
		settings.LANGUAGE_RU:
			TranslationServer.set_locale("ru")
		_:
			TranslationServer.set_locale("en")

func _on_VLanguage_item_selected(ID):
	settings.vlanguage = ID

func _on_MasterVolume_value_changed(value):
	settings.set_master_volume(value)

func _on_MusicVolume_value_changed(value):
	settings.set_music_volume(value)

func _on_SoundVolume_value_changed(value):
	settings.set_sound_volume(value)

func _on_SpeechVolume_value_changed(value):
	settings.set_speech_volume(value)
