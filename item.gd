extends VBoxContainer

var nam = null
var model_path = null

func get_model_instance():
	var instance = load(model_path) if model_path else null
	return instance.instance() if instance else null

func remove():
	self.queue_free()