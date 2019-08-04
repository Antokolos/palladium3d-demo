extends Node

func shadow_casting_enable(root, enable):
	for ch in root.get_children():
		if ch is GeometryInstance:
			ch.set_cast_shadows_setting(GeometryInstance.SHADOW_CASTING_SETTING_ON if enable else GeometryInstance.SHADOW_CASTING_SETTING_OFF)
		shadow_casting_enable(ch, enable)