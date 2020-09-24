extends Spatial

onready var pistol_player = get_node("beretta_armature/AnimationPlayer")
onready var shell_player = get_node("beretta_shell/shell_armature/AnimationPlayer")

func shoot():
	pistol_player.play("beretta_fire")
	shell_player.play("shell_armatureAction")