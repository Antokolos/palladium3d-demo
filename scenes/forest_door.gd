extends StaticBody

var opened = false
onready var anim_player = get_parent().get_node("forest_door_armature001/AnimationPlayer")

func use(player_node):
#	var hud = player_node.get_hud()
#	if hud.inventory.visible:
#		var item = hud.get_active_item()
#		if item and item.nam.begins_with("statue_"):
#			pass
	if anim_player.is_playing() or opened:
		return
	get_node("closed_door").disabled = true
	get_node("opened_door").disabled = false
	anim_player.play("ArmatureAction.001")
	$AudioStreamPlayer.play()
	opened = true

func add_highlight(player_node):
#	var hud = player_node.get_hud()
#	if hud.inventory.visible:
#		var item = hud.get_active_item()
#		if item and item.nam == "statue_apata":
#			return "E: Положить статуэтку в ларец"
#	return ""
	return "" if opened else "E: Открыть"

func remove_highlight(player_node):
	pass
