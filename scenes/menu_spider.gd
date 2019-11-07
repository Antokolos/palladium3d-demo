extends Spatial

func spider_idle():
	$AnimationTree.set("parameters/Transition/current", 0)

func spider_run():
	$AnimationTree.set("parameters/Transition/current", 1)