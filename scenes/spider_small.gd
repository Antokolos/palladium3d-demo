extends Spatial

onready var anim_player = get_node("speder_small_armature/AnimationPlayer")

func _ready():
	anim_player.get_animation("spider_rest").set_loop(true)
	anim_player.play("spider_rest")