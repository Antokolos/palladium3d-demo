extends Node

const APP_STEAM_ID = 1137270
onready var _steam = Engine.get_singleton("Steam") if Engine.has_singleton("Steam") else null

func _ready():
	if not _steam:
		return
	if _steam.restartAppIfNecessary(APP_STEAM_ID):
		return
	if not _steam.steamInit():
		return

func joy_button_to_string(button_index):
	match button_index:
		JOY_XBOX_A, JOY_SONY_X, JOY_DS_B:
			return "XBOX A | PS X | Nintendo B"
		JOY_XBOX_B, JOY_SONY_CIRCLE, JOY_DS_A:
			return "XBOX B | PS circle | Nintendo A"
		JOY_XBOX_X, JOY_SONY_SQUARE, JOY_DS_Y:
			return "XBOX X | PS square | Nintendo Y"
		JOY_XBOX_Y, JOY_SONY_TRIANGLE, JOY_DS_X:
			return "XBOX Y | PS triangle | Nintendo X"
		JOY_L:
			return "Joypad Left Shoulder Button"
		JOY_R:
			return "Joypad Right Shoulder Button"
		JOY_L2:
			return "Joypad Left Trigger"
		JOY_R2:
			return "Joypad Right Trigger"
		JOY_L3:
			return "Joypad Left Stick Click"
		JOY_R3:
			return "Joypad Right Stick Click"
		JOY_SELECT:
			return "Joypad Button Select, Nintendo -"
		JOY_START:
			return "Joypad Button Start, Nintendo +"
		JOY_DPAD_UP:
			return "Joypad DPad Up"
		JOY_DPAD_DOWN:
			return "Joypad DPad Down"
		JOY_DPAD_LEFT:
			return "Joypad DPad Left"
		JOY_DPAD_RIGHT:
			return "Joypad DPad Right"
		_:
			return "Joypad Button"

func joy_axis_to_string(axis, axis_value):
	match axis:
		JOY_AXIS_0:  # Joypad Left Stick Horizontal Axis
			return "Left Stick " + ("Left" if axis_value < 0 else "Right")
		JOY_AXIS_1:  # Joypad Left Stick Vertical Axis
			return "Left Stick " + ("Up" if axis_value < 0 else "Down")
		JOY_AXIS_2:  # Joypad Right Stick Horizontal Axis
			return "Right Stick " + ("Left" if axis_value < 0 else "Right")
		JOY_AXIS_3:  # Joypad Right Stick Vertical Axis
			return "Right Stick " + ("Up" if axis_value < 0 else "Down")
	return "Stick " + ("-" if axis_value < 0 else "+")

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

func get_action_key(act):
	var list = InputMap.get_action_list(act)
	for action in list:
		if action is InputEventKey:
			return action.as_text() + ": "
	return ""

func is_event_cancel_action(event):
	var is_key = event is InputEventKey
	var is_joy = event is InputEventJoypadButton
	if not is_key and not is_joy:
		return false
	return event.is_action_pressed("ui_cancel")

func set_achievement(achievement_name):
	if not is_steam_running():
		return null
	return _steam.setAchievement(achievement_name)

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
	return _steam and _steam.isSteamRunning()