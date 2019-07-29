extends Spatial

func _ready():
	get_node("door_1_armat/AnimationPlayer").play_backwards("door_1")
	get_node("StaticBody/CollisionShape").disabled = true

func close():
	get_node("door_1_armat/AnimationPlayer").play("door_1")
	get_node("StaticBody/CollisionShape").disabled = false