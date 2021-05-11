extends Position3D
class_name PLDRatSource

func restore_rat(and_make_absent = true):
	var rat = create_rat()
	add_child(rat)
	if and_make_absent:
		rat.make_absent()

static func create_rat():
	var rat = load("res://addons/palladium/scenes/rat.tscn").instance()
	var rat_model_holder = Spatial.new()
	rat_model_holder.set_scale(Vector3(1.5, 1.5, 1.5))
	rat_model_holder.set_name("Model")
	var rat_model = load("res://scenes/rat_grey.tscn").instance()
	rat_model_holder.add_child(rat_model)
	rat.add_child(rat_model_holder)
	rat.set_volatile_path(true)
	return rat