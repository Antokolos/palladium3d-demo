extends Node

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

func open_url(url):
	# TODO: replace with call to GodotSteam
	OS.shell_open(url)

func open_store_page(steam_appid):
	# TODO: replace with call to GodotSteam
	open_url("https://store.steampowered.com/app/%d" % steam_appid)

func is_steam_running():
	# TODO: replace with call to GodotSteam
	return true