extends Spatial

func _ready():
	get_node("door_4_armature001/AnimationPlayer").play("door_4_armatureAction.001")
	get_node("StaticBody/CollisionShape").disabled = true

func close():
	get_node("door_4_armature001/AnimationPlayer").play_backwards("door_4_armatureAction.001")
	get_node("StaticBody/CollisionShape").disabled = false