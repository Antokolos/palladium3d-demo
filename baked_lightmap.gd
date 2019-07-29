extends BakedLightmap

var calculated_light_data = null

func _ready():
	calculated_light_data = get_light_data()

func enable(enable):
	if enable:
		set_light_data(calculated_light_data)
	else:
		set_light_data(null)