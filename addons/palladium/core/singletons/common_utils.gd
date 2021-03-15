extends Node

const APP_STEAM_ID = 1137270
onready var _steam = Engine.get_singleton("Steam") if Engine.has_singleton("Steam") else null

func _ready():
	Input.connect("joy_connection_changed", self, "_on_joy_connection_changed")
	if not _steam:
		return
	if _steam.restartAppIfNecessary(APP_STEAM_ID):
		return
	_steam.steamInit()

# Returns true if connected joypads are present, false otherwise
func has_joypads():
	return Input.get_connected_joypads().size() > 0

func _on_joy_connection_changed(device_id, is_connected):
	if not is_connected:
		if not get_tree().paused:
			# When the controller is unplugged during gameplay, automatically pause the game
			toggle_pause_menu()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		var viewport = game_state.get_viewport()
		viewport.warp_mouse(Vector2(OS.window_size.x / 2, OS.window_size.y / 2))

func show_mouse_cursor_if_needed(show, force = false):
	if show:
		Input.set_mouse_mode(
			Input.MOUSE_MODE_VISIBLE
				if force or not has_joypads()
				else Input.MOUSE_MODE_CAPTURED
		)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func show_mouse_cursor_if_needed_in_game(hud):
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE if hud.is_menu_hud() else Input.MOUSE_MODE_CAPTURED)

func toggle_pause_menu():
	var ev = InputEventAction.new()
	ev.set_action("ui_tablet_toggle")
	ev.set_pressed(true)
	get_tree().input_event(ev)

func joy_button_to_string(button_index):
	match button_index:
		JOY_XBOX_A, JOY_SONY_X, JOY_DS_B:
			match settings.joypad_type:
				PLDSettings.JOYPAD_XBOX:
					return "[A]"
				PLDSettings.JOYPAD_PS:
					return "[X]"
				PLDSettings.JOYPAD_NINTENDO:
					return "[B]"
				_:
					return "[?]"
		JOY_XBOX_B, JOY_SONY_CIRCLE, JOY_DS_A:
			match settings.joypad_type:
				PLDSettings.JOYPAD_XBOX:
					return "[B]"
				PLDSettings.JOYPAD_PS:
					return "[Circle]"
				PLDSettings.JOYPAD_NINTENDO:
					return "[A]"
				_:
					return "[?]"
		JOY_XBOX_X, JOY_SONY_SQUARE, JOY_DS_Y:
			match settings.joypad_type:
				PLDSettings.JOYPAD_XBOX:
					return "[X]"
				PLDSettings.JOYPAD_PS:
					return "[Square]"
				PLDSettings.JOYPAD_NINTENDO:
					return "[Y]"
				_:
					return "[?]"
		JOY_XBOX_Y, JOY_SONY_TRIANGLE, JOY_DS_X:
			match settings.joypad_type:
				PLDSettings.JOYPAD_XBOX:
					return "[Y]"
				PLDSettings.JOYPAD_PS:
					return "[Triangle]"
				PLDSettings.JOYPAD_NINTENDO:
					return "[X]"
				_:
					return "[?]"
		JOY_L:
			return "[LB]" # "Joypad Left Shoulder Button"
		JOY_R:
			return "[RB]" # "Joypad Right Shoulder Button"
		JOY_L2:
			return "[LT]" # "Joypad Left Trigger"
		JOY_R2:
			return "[RT]" # "Joypad Right Trigger"
		JOY_L3:
			return "[LS Click]" # "Joypad Left Stick Click"
		JOY_R3:
			return "[RS Click]" # "Joypad Right Stick Click"
		JOY_SELECT:
			match settings.joypad_type:
				PLDSettings.JOYPAD_NINTENDO:
					return "[-]"
				_:
					return "[Select]"
		JOY_START:
			match settings.joypad_type:
				PLDSettings.JOYPAD_NINTENDO:
					return "[+]"
				_:
					return "[Start]"
		JOY_DPAD_UP:
			return "DPad Up"
		JOY_DPAD_DOWN:
			return "DPad Down"
		JOY_DPAD_LEFT:
			return "DPad Left"
		JOY_DPAD_RIGHT:
			return "DPad Right"
		_:
			return "[?]"

func joy_axis_to_string(axis, axis_value):
	match axis:
		JOY_AXIS_0:  # Joypad Left Stick Horizontal Axis
			return "[LS " + ("Left]" if axis_value < 0 else "Right]")
		JOY_AXIS_1:  # Joypad Left Stick Vertical Axis
			return "[LS " + ("Up]" if axis_value < 0 else "Down]")
		JOY_AXIS_2:  # Joypad Right Stick Horizontal Axis
			return "[RS " + ("Left]" if axis_value < 0 else "Right]")
		JOY_AXIS_3:  # Joypad Right Stick Vertical Axis
			return "[RS " + ("Up]" if axis_value < 0 else "Down]")
	return "[Stick " + ("-]" if axis_value < 0 else "+]")

func mouse_button_to_string(button_index):
	match button_index:
		BUTTON_LEFT:
			return "Left Button"
		BUTTON_RIGHT:
			return "Right Button"
		BUTTON_MIDDLE:
			return "Middle Button"
		BUTTON_WHEEL_UP:
			return "Mouse wheel up"
		BUTTON_WHEEL_DOWN:
			return "Mouse wheel down"
		BUTTON_WHEEL_LEFT:
			return "Mouse wheel left"
		BUTTON_WHEEL_RIGHT:
			return "Mouse wheel right"
		BUTTON_XBUTTON1:
			return "Extra Button 1"
		BUTTON_XBUTTON2:
			return "Extra Button 2"
		_:
			return "Extended button " + str(button_index)

# log() in Godot is actually a NATURAL logarithm
# This method returns a 10-based logarithm
func log10(x):
	return log(x) / log(10.0)

#(Un)pauses a single node
func set_pause_node(node : Node, pause : bool) -> void:
	if node is Timer:
		return
	node.set_process(!pause)
	node.set_process_input(!pause)
	node.set_process_internal(!pause)
	node.set_physics_process(!pause)
	node.set_physics_process_internal(!pause)
	node.set_process_unhandled_input(!pause)
	node.set_process_unhandled_key_input(!pause)

#(Un)pauses a scene
#Ignored childs is an optional argument, that contains the path of nodes whose state must not be altered by the function
func set_pause_scene(rootNode : Node, pause : bool, ignoredChilds : PoolStringArray = [null]):
	set_pause_node(rootNode, pause)
	for node in rootNode.get_children():
		if not (String(node.get_path()) in ignoredChilds):
			set_pause_scene(node, pause, ignoredChilds)

func shadow_casting_enable(root, enable):
	var s = GeometryInstance.SHADOW_CASTING_SETTING_ON if enable else GeometryInstance.SHADOW_CASTING_SETTING_OFF
	for ch in root.get_children():
		if ch is GeometryInstance:
			ch.set_cast_shadows_setting(s)
		shadow_casting_enable(ch, enable)

func get_input_control(act, with_colon = true):
	var list = InputMap.get_action_list(act)
	var has_joypads = has_joypads()
	var trail = ": " if with_colon else ""
	for action in list:
		if not has_joypads and action is InputEventKey:
			return action.as_text() + trail
		elif has_joypads and action is InputEventJoypadButton:
			var button_index = action.get_button_index()
			return joy_button_to_string(button_index) + trail
		elif has_joypads and action is InputEventJoypadMotion:
			var axis = action.get_axis()
			var axis_value = action.get_axis_value()
			return joy_axis_to_string(axis, axis_value) + trail
	return ""

func get_action_input_control():
	return get_input_control("action")

func is_event_cancel_action(event):
	var is_key = event is InputEventKey
	var is_joy = event is InputEventJoypadButton
	if not is_key and not is_joy:
		return false
	return event.is_action_pressed("ui_cancel")

func clear_achievement(achievement_name, and_store_stats = true):
	if not is_steam_running():
		return false
	var result = _steam.clearAchievement(achievement_name)
	if and_store_stats:
		store_stats()
	return result

func set_achievement(achievement_name, and_store_stats = true):
	if not is_steam_running():
		return false
	var result = _steam.setAchievement(achievement_name)
	if and_store_stats:
		store_stats()
	return result

func set_achievement_progress(achievement_name, progress_current, progress_max, and_store_stats = true):
	if not is_steam_running():
		return false
	var result = _steam.indicateAchievementProgress(achievement_name, progress_current, progress_max)
	if and_store_stats:
		store_stats()
	return result

func set_stat_int(stat_name, stat_value, and_store_stats = true):
	if not is_steam_running():
		return false
	var result = _steam.setStatInt(stat_name, stat_value)
	if and_store_stats:
		store_stats()
	return result

func store_stats():
	if not is_steam_running():
		return null
	return _steam.storeStats()

func open_url(url):
	if is_steam_running():
		_steam.activateGameOverlayToWebPage(url)
	else:
		OS.shell_open(url)

func open_store_page(steam_appid):
	if is_steam_running():
		_steam.activateGameOverlayToStore(steam_appid)
	else:
		open_url("https://store.steampowered.com/app/%d" % steam_appid)

func is_steam_running():
	return _steam and _steam.isSteamRunning() and _steam.loggedOn()