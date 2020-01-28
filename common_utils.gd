extends Node

func shadow_casting_enable(root, enable):
	var s = GeometryInstance.SHADOW_CASTING_SETTING_ON if enable else GeometryInstance.SHADOW_CASTING_SETTING_OFF
	for ch in root.get_children():
		if ch is GeometryInstance:
			ch.set_cast_shadows_setting(s)
		shadow_casting_enable(ch, enable)