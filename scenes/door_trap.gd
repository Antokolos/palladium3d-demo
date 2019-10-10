extends Spatial

func _ready():
	get_node("door_4_armature/AnimationPlayer").play("door_4_armatureAction")
	get_node("StaticBody/CollisionShape").disabled = true

func close():
	get_node("door_4_armature/AnimationPlayer").play_backwards("door_4_armatureAction")
	get_node("StaticBody/CollisionShape").disabled = false