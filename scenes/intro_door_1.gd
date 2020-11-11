extends Spatial

onready var anim_player = get_node("Armature001/AnimationPlayer")

func _ready():
	anim_player.play("door_opens")
	anim_player.seek(2.2, true)
	anim_player.stop(false)

func anim_start():
	anim_player.play("door_opens")
