extends Spatial

func set_transition(t):
	var transition = $AnimationTree.get("parameters/Transition/current")
	if transition != t:
		$AnimationTree.set("parameters/Transition/current", t)

func rest():
	set_transition(0)

func rest_sniff():
	set_transition(1)

func sits_sniff():
	set_transition(2)

func run():
	set_transition(5)