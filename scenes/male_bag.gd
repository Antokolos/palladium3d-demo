extends Spatial

onready var anim_player = get_node("Andreas_bag_Armature/AnimationPlayer")

func being_carried():
	anim_player.play("male_bag_beingcarried_2")
