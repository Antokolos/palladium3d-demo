extends PLDCharacter
class_name PLDEnemy

func _ready():
	pass

func _on_CutsceneTimer_timeout():
	set_look_transition(true)