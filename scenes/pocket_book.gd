extends Spatial

func _ready():
	get_node("pocket_book_armature/AnimationPlayer").play("book_idle")