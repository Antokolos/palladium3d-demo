extends Spatial

var opened = false
onready var anim_player = get_node("Armature008/AnimationPlayer")

func open():
	if anim_player.is_playing():
		anim_player.stop(false)
	anim_player.play("Armature.010Action.000")

func close():
	if anim_player.is_playing():
		anim_player.stop(false)
	anim_player.play_backwards("Armature.010Action.000")