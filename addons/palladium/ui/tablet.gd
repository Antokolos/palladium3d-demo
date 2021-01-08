extends Control
class_name PLDTablet

const SENS_FORMAT = "%0.2f"

onready var tablet_panel = get_node("TabletPanel")
onready var home_button = get_node("TabletPanel/HomeButton")
onready var desktop = get_node("TabletPanel/TabletScreen/desktop")
onready var desktop_containers = desktop.get_node("GridContainer")
onready var desktop_container_chat = desktop_containers.get_node("VChatContainer")
onready var desktop_container_credits = desktop_containers.get_node("VCreditsContainer")
onready var desktop_container_map = desktop_containers.get_node("VMapContainer")
onready var desktop_container_documents = desktop_containers.get_node("VDocumentsContainer")
onready var desktop_container_settings = desktop_containers.get_node("VSettingsContainer")
onready var desktop_container_save = desktop_containers.get_node("VSaveGameContainer")
onready var save_button = desktop_container_save.get_node("HContainer/SaveGameButton")
onready var save_button_label = desktop_container_save.get_node("Label")
onready var save_button_label_disabled = desktop_container_save.get_node("LabelDisabled")
onready var desktop_container_load = desktop_containers.get_node("VLoadGameContainer")
onready var desktop_container_quit = desktop_containers.get_node("VQuitGameContainer")
onready var apps = get_node("TabletPanel/TabletScreen/apps")
onready var chat = apps.get_node("chat")
onready var credits = apps.get_node("credits")
onready var settings_app = apps.get_node("settings_app")
onready var controls_app = apps.get_node("controls_app")
onready var save_game_app = apps.get_node("save_game_app")
onready var load_game_app = apps.get_node("load_game_app")
onready var tablet_orientation = settings_app.get_node("VBoxContainer/HTabletOrientation/TabletOrientation")
onready var vsync = settings_app.get_node("VBoxContainer/HVsync/Vsync")
onready var fullscreen = settings_app.get_node("VBoxContainer/HFullscreen/Fullscreen")
onready var invert_yaxis = settings_app.get_node("VBoxContainer/HInvertYAxis/InvertYAxis")
onready var cutoff_enabled = settings_app.get_node("VBoxContainer/HCutoffEnabled/CutoffEnabled")
onready var shader_cache_enabled = settings_app.get_node("VBoxContainer/HShaderCacheEnabled/ShaderCacheEnabled")
onready var quality = settings_app.get_node("VBoxContainer/HQuality/Quality")
onready var resolution = settings_app.get_node("VBoxContainer/HResolution/Resolution")
onready var aa = settings_app.get_node("VBoxContainer/HAA/AA")
onready var language = settings_app.get_node("VBoxContainer/HLanguage/Language")
onready var vlanguage = settings_app.get_node("VBoxContainer/HVLanguage/VLanguage")
onready var subtitles = settings_app.get_node("VBoxContainer/HSubtitles/Subtitles")
onready var sensitivity_coef_node = settings_app.get_node("VBoxContainer/HSensitivityCoef/VBoxContainer/SensitivityCoef")
onready var sensitivity_coef_label_node = settings_app.get_node("VBoxContainer/HSensitivityCoef/VBoxContainer/Label")
onready var master_volume_node = settings_app.get_node("VBoxContainer/HMasterVolume/MasterVolume")
onready var music_volume_node = settings_app.get_node("VBoxContainer/HMusicVolume/MusicVolume")
onready var sound_volume_node = settings_app.get_node("VBoxContainer/HSoundVolume/SoundVolume")
onready var speech_volume_node = settings_app.get_node("VBoxContainer/HSpeechVolume/SpeechVolume")

enum ActivationMode {DESKTOP, CHAT, CREDITS, MAP, DOCUMENTS, SETTINGS, SAVE, LOAD}

onready var hud = get_parent()

func _ready():
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

	invert_yaxis.pressed = settings.invert_yaxis
	_on_InvertYAxis_pressed()

	cutoff_enabled.pressed = settings.cutoff_enabled
	_on_CutoffEnabled_pressed()

	shader_cache_enabled.pressed = settings.shader_cache_enabled
	_on_ShaderCacheEnabled_pressed()

	sensitivity_coef_node.value = common_utils.log10(settings.sensitivity_coef)
	_on_SensitivityCoef_value_changed(sensitivity_coef_node.value)

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
	for r in settings.resolutions:
		resolution.add_item("%d x %d" % [ssize.x * settings.resolutions[i].height / ssize.y, settings.resolutions[i].height], i)
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
	vlanguage.add_item("English", settings.VLANGUAGE_EN)
	match (settings.vlanguage):
		settings.VLANGUAGE_NONE:
			vlanguage.select(0)
		settings.VLANGUAGE_RU:
			vlanguage.select(1)
		settings.VLANGUAGE_EN:
			vlanguage.select(2)
		_:
			language.select(0)
	_on_VLanguage_item_selected(settings.vlanguage)
	
	subtitles.pressed = settings.subtitles
	_on_Subtitles_pressed()
	
	master_volume_node.value = settings.master_volume
	music_volume_node.value = settings.music_volume
	sound_volume_node.value = settings.sound_volume
	speech_volume_node.value = settings.speech_volume

func activate(mode):
	visible = true
	if hud.is_menu_hud():
		desktop_container_chat.visible = false
		desktop_container_credits.visible = true
		desktop_container_map.visible = false
		desktop_container_documents.visible = false
		desktop_container_settings.visible = true
		desktop_container_save.visible = false
		desktop_container_load.visible = true
		desktop_container_quit.visible = true
	else:
		var can_load = hud.has_game_ui() and not cutscene_manager.is_cutscene()
		desktop_container_chat.visible = true
		desktop_container_credits.visible = false
		desktop_container_map.visible = false
		desktop_container_documents.visible = false
		desktop_container_settings.visible = true
		desktop_container_save.visible = can_load
		if game_state.is_saving_disabled():
			save_button.disabled = true
			save_button_label.visible = false
			save_button_label_disabled.visible = true
		else:
			save_button.disabled = false
			save_button_label.visible = true
			save_button_label_disabled.visible = false
		desktop_container_load.visible = can_load
		desktop_container_quit.visible = true
	match mode:
		ActivationMode.CHAT:
			_on_ChatButton_pressed()
		ActivationMode.CREDITS:
			_on_CreditsButton_pressed()
		ActivationMode.SETTINGS:
			_on_SettingsButton_pressed()
		ActivationMode.SAVE:
			_on_SaveGameButton_pressed()
		ActivationMode.LOAD:
			_on_LoadGameButton_pressed()
		ActivationMode.MAP:
			continue
		ActivationMode.DOCUMENTS:
			continue
		ActivationMode.DESKTOP:
			continue
		_:
			_on_HomeButton_pressed()

func _unhandled_input(event):
	if get_tree().paused and event.is_action_pressed("ui_tablet_toggle"):
		get_tree().set_input_as_handled()
		hud.show_tablet(false)

func hide_everything():
	for node in apps.get_children():
		node.hide()
	desktop.hide()

func _on_HomeButton_pressed():
	hide_everything()
	desktop.show()

func _on_CloseButton_pressed():
	simulate_esc()

func _on_ChatButton_pressed():
	hide_everything()
	chat.load_chat()
	chat.show()

func _on_CreditsButton_pressed():
	hide_everything()
	credits.activate()

func _on_SettingsButton_pressed():
	hide_everything()
	settings_app.show()

func _on_ControlsButton_pressed():
	hide_everything()
	controls_app.show()
	controls_app.refresh()

func refresh_slot_captions(is_load, base_node):
	var starting_slot = 0 if is_load else 1
	for i in range(starting_slot, 6):
		var node = base_node.get_node("VBoxContainer/Slot%d/ButtonSlot%d" % [i, i])
		var caption = story_node.get_slot_caption(i)
		var exists = game_state.save_slot_exists(i)
		node.set_disabled(is_load and not exists)
		if i > 0:
			node.text = caption if exists else tr("TABLET_EMPTY_SLOT")
		else: # i == 0
			node.text = tr("TABLET_AUTOSAVE_SLOT") + (": " + caption if exists else "")

func _on_SaveGameButton_pressed():
	hide_everything()
	save_game_app.show()
	refresh_slot_captions(false, save_game_app)

func _on_LoadGameButton_pressed():
	hide_everything()
	load_game_app.show()
	refresh_slot_captions(true, load_game_app)

func _on_QuitGameButton_pressed():
	get_tree().notify_group("quit_dialog", MainLoop.NOTIFICATION_WM_QUIT_REQUEST)

func simulate_esc():
	# Why we need such workarounds?
	# Why not just call hud.show_tablet(false) and set mouse mode to Input.MOUSE_MODE_CAPTURED?
	# Well, I tried, but I failed, for some reason it didn't work for me and I don't know why.
	# If you'll simplify this code, please tell me, what am I doing wrong :(
	var ev = InputEventAction.new()
	ev.set_action("ui_tablet_toggle")
	ev.set_pressed(true)
	get_tree().input_event(ev)
	if not hud.is_menu_hud():
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func save_to_slot(slot):
	game_state.save_state(slot)
	simulate_esc()

func load_from_slot(slot):
	game_state.initiate_load(slot)
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

func _on_ButtonSlot0_pressed():
	game_state.autosave_restore()
	simulate_esc()

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
	settings.set_vsync(vs)

func _on_Fullscreen_pressed():
	var fs = fullscreen.is_pressed() if fullscreen else settings.fullscreen
	settings.set_fullscreen(fs)

func _on_InvertYAxis_pressed():
	var enabled = invert_yaxis.is_pressed() if invert_yaxis else settings.invert_yaxis
	settings.set_invert_yaxis(enabled)

func _on_SensitivityCoef_value_changed(value):
	var v = pow(10.0, value)
	settings.set_sensitivity_coef(v)
	sensitivity_coef_label_node.text = SENS_FORMAT % v

func _on_CutoffEnabled_pressed():
	var ce = cutoff_enabled.is_pressed() if cutoff_enabled else settings.cutoff_enabled
	settings.set_cutoff_enabled(ce)

func _on_ShaderCacheEnabled_pressed():
	var sce = shader_cache_enabled.is_pressed() if shader_cache_enabled else settings.shader_cache_enabled
	settings.set_shader_cache_enabled(sce)

func _on_Quality_item_selected(ID):
	settings.set_quality(ID)

func _on_Resolution_item_selected(ID):
	settings.set_resolution(ID)

func _on_AA_item_selected(ID):
	var viewport = game_state.get_viewport()
	if (ID == settings.AA_8X):
		viewport.msaa = Viewport.MSAA_8X
	elif (ID == settings.AA_4X):
		viewport.msaa = Viewport.MSAA_4X
	elif (ID == settings.AA_2X):
		viewport.msaa = Viewport.MSAA_2X
	else:
		viewport.msaa = Viewport.MSAA_DISABLED
	settings.aa_quality = ID

func _on_Language_item_selected(ID):
	settings.set_language(ID)

func _on_VLanguage_item_selected(ID):
	settings.vlanguage = ID

func _on_Subtitles_pressed():
	var s = subtitles.is_pressed() if subtitles else settings.subtitles
	settings.set_subtitles(s)

func _on_MasterVolume_value_changed(value):
	settings.set_master_volume(value)

func _on_MusicVolume_value_changed(value):
	settings.set_music_volume(value)

func _on_SoundVolume_value_changed(value):
	settings.set_sound_volume(value)

func _on_SpeechVolume_value_changed(value):
	settings.set_speech_volume(value)
