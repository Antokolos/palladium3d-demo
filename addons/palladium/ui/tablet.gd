extends Control
class_name PLDTablet

const SENS_FORMAT = "%0.2f"
const ADJUST_FORMAT = "%0.2f"

onready var tablet_panel = get_node("TabletPanel")
onready var home_button = get_node("TabletPanel/HomeButton")
onready var desktop = get_node("TabletPanel/TabletScreen/desktop")
onready var desktop_containers = desktop.get_node("GridContainer")
onready var desktop_container_chat = desktop_containers.get_node("VChatContainer")
onready var desktop_container_credits = desktop_containers.get_node("VCreditsContainer")
onready var desktop_container_map = desktop_containers.get_node("VMapContainer")
onready var desktop_container_documents = desktop_containers.get_node("VDocumentsContainer")
onready var desktop_container_settings = desktop_containers.get_node("VSettingsContainer")
onready var settings_button = desktop_container_settings.get_node("HContainer/SettingsButton")
onready var desktop_container_save = desktop_containers.get_node("VSaveGameContainer")
onready var save_button = desktop_container_save.get_node("HContainer/SaveGameButton")
onready var save_button_label = desktop_container_save.get_node("Label")
onready var save_button_label_disabled = desktop_container_save.get_node("LabelDisabled")
onready var desktop_container_load = desktop_containers.get_node("VLoadGameContainer")
onready var desktop_container_quit = desktop_containers.get_node("VQuitGameContainer")
onready var apps = get_node("TabletPanel/TabletScreen/apps")
onready var chat = apps.get_node("chat")
onready var chat_window = chat.get_node('VBoxContainer/ChatWindow')
onready var credits = apps.get_node("credits")
onready var settings_app = apps.get_node("settings_app")
onready var controls_app = apps.get_node("controls_app")
onready var save_game_app = apps.get_node("save_game_app")
onready var first_save_slot_button = save_game_app.get_node("VBoxContainer/Slot1/ButtonSlot1")
onready var load_game_app = apps.get_node("load_game_app")
onready var autosave_load_button = load_game_app.get_node("VBoxContainer/Slot0/ButtonSlot0")
onready var tablet_orientation = settings_app.get_node("VBoxContainer/HTabletOrientation/TabletOrientation")
onready var joypad_type_parent = settings_app.get_node("VBoxContainer/HJoypadType")
onready var joypad_type = joypad_type_parent.get_node("JoypadType")
onready var vsync = settings_app.get_node("VBoxContainer/HVsync/Vsync")
onready var fullscreen = settings_app.get_node("VBoxContainer/HFullscreen/Fullscreen")
onready var invert_yaxis = settings_app.get_node("VBoxContainer/HInvertYAxis/InvertYAxis")
onready var cutoff_enabled = settings_app.get_node("VBoxContainer/HCutoffEnabled/CutoffEnabled")
onready var shader_cache_enabled = settings_app.get_node("VBoxContainer/HShaderCacheEnabled/ShaderCacheEnabled")
onready var pause_on_joypad_disconnected_parent = settings_app.get_node("VBoxContainer/HJoypadType/HPauseOnJoypadDisconnected")
onready var pause_on_joypad_disconnected = pause_on_joypad_disconnected_parent.get_node("PauseOnJoypadDisconnected")
onready var disable_mouse_if_joypad_connected_parent = settings_app.get_node("VBoxContainer/HDisableMouseIfJoypadConnected")
onready var disable_mouse_if_joypad_connected = disable_mouse_if_joypad_connected_parent.get_node("DisableMouseIfJoypadConnected")
onready var quality = settings_app.get_node("VBoxContainer/HQuality/Quality")
onready var difficulty = settings_app.get_node("VBoxContainer/HDifficulty/Difficulty")
onready var resolution = settings_app.get_node("VBoxContainer/HQuality/HResolution/Resolution")
onready var aa = settings_app.get_node("VBoxContainer/HAA/AA")
onready var language = settings_app.get_node("VBoxContainer/HLanguage/Language")
onready var vlanguage = settings_app.get_node("VBoxContainer/HLanguage/HVLanguage/VLanguage")
onready var subtitles = settings_app.get_node("VBoxContainer/HLanguage/HSubtitles/Subtitles")
onready var sensitivity_coef_node = settings_app.get_node("VBoxContainer/HSensitivityCoef/VBoxContainer/SensitivityCoef")
onready var sensitivity_coef_label_node = settings_app.get_node("VBoxContainer/HSensitivityCoef/VBoxContainer/Label")
onready var master_volume_node = settings_app.get_node("VBoxContainer/HMasterVolume/MasterVolume")
onready var music_volume_node = settings_app.get_node("VBoxContainer/HMusicVolume/MusicVolume")
onready var sound_volume_node = settings_app.get_node("VBoxContainer/HSoundVolume/SoundVolume")
onready var speech_volume_node = settings_app.get_node("VBoxContainer/HSpeechVolume/SpeechVolume")
onready var use_image_adjust = settings_app.get_node("VBoxContainer/HImageAdjust/UseImageAdjust")
onready var brightness = settings_app.get_node("VBoxContainer/HBoxBrightness/BoxBrightness/Brightness")
onready var brightness_value = settings_app.get_node("VBoxContainer/HBoxBrightness/BoxBrightness/HBoxContainer/LabelValue")
onready var contrast = settings_app.get_node("VBoxContainer/HBoxContrast/BoxContrast/Contrast")
onready var contrast_value = settings_app.get_node("VBoxContainer/HBoxContrast/BoxContrast/HBoxContainer/LabelValue")
onready var saturation = settings_app.get_node("VBoxContainer/HBoxSaturation/BoxSaturation/Saturation")
onready var saturation_value = settings_app.get_node("VBoxContainer/HBoxSaturation/BoxSaturation/HBoxContainer/LabelValue")

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

	joypad_type.add_item("XBOX", settings.JOYPAD_XBOX)
	joypad_type.add_item("PlayStation", settings.JOYPAD_PS)
	joypad_type.add_item("NINTENDO", settings.JOYPAD_NINTENDO)
	match (settings.joypad_type):
		settings.JOYPAD_XBOX:
			joypad_type.select(0)
		settings.JOYPAD_PS:
			joypad_type.select(1)
		settings.JOYPAD_NINTENDO:
			joypad_type.select(2)
	_on_JoypadType_item_selected(settings.joypad_type)

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

	pause_on_joypad_disconnected.pressed = settings.pause_on_joy_disconnected
	_on_PauseOnJoypadDisconnected_pressed()

	disable_mouse_if_joypad_connected.pressed = settings.disable_mouse_if_joy_connected
	_on_DisableMouseIfJoypadConnected_pressed()

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

	difficulty.add_item(tr("SETTINGS_DIFFICULTY_NORMAL"), PLDSettings.DIFFICULTY_NORMAL)
	difficulty.add_item(tr("SETTINGS_DIFFICULTY_HARD"), PLDSettings.DIFFICULTY_HARD)
	match (settings.difficulty):
		PLDSettings.DIFFICULTY_NORMAL:
			difficulty.select(0)
		PLDSettings.DIFFICULTY_HARD:
			difficulty.select(1)
	# _on_Difficulty_item_selected(settings.difficulty) -- not needed here, will be done on player _ready

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
	
	use_image_adjust.pressed = settings.use_image_adjust
	brightness.value = settings.brightness
	contrast.value = settings.contrast
	saturation.value = settings.saturation
	_on_UseImageAdjust_pressed()

func activate(mode):
	visible = true
	var has_joypads = common_utils.has_joypads()
	joypad_type_parent.visible = has_joypads
	pause_on_joypad_disconnected_parent.visible = has_joypads
	disable_mouse_if_joypad_connected_parent.visible = has_joypads
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
		var is_not_cutscene = hud.has_game_ui() and not cutscene_manager.is_cutscene()
		desktop_container_chat.visible = is_not_cutscene
		desktop_container_credits.visible = false
		desktop_container_map.visible = false
		desktop_container_documents.visible = false
		desktop_container_settings.visible = true
		desktop_container_save.visible = is_not_cutscene
		if game_state.is_saving_disabled():
			save_button.disabled = true
			save_button_label.visible = false
			save_button_label_disabled.visible = true
		else:
			save_button.disabled = false
			save_button_label.visible = true
			save_button_label_disabled.visible = false
		desktop_container_load.visible = is_not_cutscene
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
	if not get_tree().paused or game_state.is_video_cutscene():
		return
	if event.is_action_pressed("ui_tablet_toggle"):
		get_tree().set_input_as_handled()
		hud.show_tablet(false)
	elif event.is_action_pressed("ui_cancel"):
		if desktop.visible:
			_on_CloseButton_pressed()
		else:
			_on_HomeButton_pressed()

func hide_everything():
	for node in apps.get_children():
		node.hide()
	desktop.hide()

func _on_HomeButton_pressed():
	hide_everything()
	desktop.show()
	settings_button.grab_focus()

func _on_CloseButton_pressed():
	simulate_esc()

func _on_ChatButton_pressed():
	hide_everything()
	chat.load_chat()
	chat.show()
	chat_window.grab_focus()

func _on_CreditsButton_pressed():
	hide_everything()
	credits.activate()
	home_button.grab_focus()

func _on_SettingsButton_pressed():
	hide_everything()
	settings_app.show()
	vsync.grab_focus()

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
	first_save_slot_button.grab_focus()

func _on_LoadGameButton_pressed():
	hide_everything()
	load_game_app.show()
	refresh_slot_captions(true, load_game_app)
	autosave_load_button.grab_focus()

func _on_QuitGameButton_pressed():
	get_tree().notify_group("quit_dialog", MainLoop.NOTIFICATION_WM_QUIT_REQUEST)

func simulate_esc():
	# Why we need such workarounds?
	# Why not just call hud.show_tablet(false) and set mouse mode to Input.MOUSE_MODE_CAPTURED?
	# Well, I tried, but I failed, for some reason it didn't work for me and I don't know why.
	# If you'll simplify this code, please tell me, what am I doing wrong :(
	common_utils.toggle_pause_menu()
	common_utils.show_mouse_cursor_if_needed_in_game(hud)

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

func _on_JoypadType_item_selected(ID):
	settings.joypad_type = ID

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

func _on_PauseOnJoypadDisconnected_pressed():
	var pjd = pause_on_joypad_disconnected.is_pressed() if pause_on_joypad_disconnected else settings.pause_on_joy_disconnected
	settings.set_pause_on_joy_disconnected(pjd)

func _on_DisableMouseIfJoypadConnected_pressed():
	var mjc = disable_mouse_if_joypad_connected.is_pressed() if disable_mouse_if_joypad_connected else settings.disable_mouse_if_joy_connected
	settings.set_disable_mouse_if_joy_connected(mjc)

func _on_Quality_item_selected(ID):
	settings.set_quality(ID)

func _on_Difficulty_item_selected(ID):
	settings.set_difficulty(ID)

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

func _on_UseImageAdjust_pressed():
	var ia = use_image_adjust.is_pressed() if use_image_adjust else settings.use_image_adjust
	settings.set_use_image_adjust(ia)
	if brightness:
		brightness.get_parent().get_parent().visible = ia
	if contrast:
		contrast.get_parent().get_parent().visible = ia
	if saturation:
		saturation.get_parent().get_parent().visible = ia

func _on_Brightness_value_changed(value):
	settings.set_brightness(value)
	brightness_value.text = ADJUST_FORMAT % value

func _on_Contrast_value_changed(value):
	settings.set_contrast(value)
	contrast_value.text = ADJUST_FORMAT % value

func _on_Saturation_value_changed(value):
	settings.set_saturation(value)
	saturation_value.text = ADJUST_FORMAT % value
