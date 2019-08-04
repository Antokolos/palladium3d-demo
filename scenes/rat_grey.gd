extends Spatial

func set_transition(initial_transition, last_transition):
	var transition = $AnimationTree.get("parameters/Transition/current")
	if transition < initial_transition or transition > last_transition:
		$AnimationTree.set("parameters/Transition/current", initial_transition)

func rest():
	set_transition(0, 0)

func rest_sniff():
	set_transition(1, 1)

func sits_sniff():
	set_transition(2, 4)

func run():
	set_transition(5, 5)