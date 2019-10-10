extends Spatial

onready var bark_maple_material = load("res://assets/bark_maple_shader.tres")
onready var leaf_maple_material = load("res://assets/leaf_maple_shader.tres")

func _ready():
	bark_maple_material.set("shader_param/sway_speed", 2.0)
	bark_maple_material.set("shader_param/sway_strength", 0.05)
	bark_maple_material.set("shader_param/sway_phase_len", 8.0)
	leaf_maple_material.set("shader_param/sway_speed", 2.0)
	leaf_maple_material.set("shader_param/sway_strength", 0.05)
	leaf_maple_material.set("shader_param/sway_phase_len", 8.0)

func wind_effect_enable(enable):
	var mesh = get_node("tree_maple")
	mesh.set_surface_material(0, bark_maple_material if enable else null)
	mesh.set_surface_material(1, leaf_maple_material if enable else null)