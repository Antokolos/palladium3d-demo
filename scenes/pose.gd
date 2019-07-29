extends Spatial

export var anim_player_path = "Statue/AnimationPlayer"
export var anim_name = "StatueAction"
export var statue_name = "statue_urania"

func _ready():
	var anim_player = get_node(anim_player_path)
	anim_player.get_animation(anim_name).set_loop(true)
	anim_player.play(anim_name)
