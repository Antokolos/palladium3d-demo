extends Spatial

onready var leaf_maple_2_material = load("res://assets/branch_maple_2_shader.tres")

func _ready():
	leaf_maple_2_material.set("shader_param/sway_speed", 2.0)
	leaf_maple_2_material.set("shader_param/sway_strength", 0.05)
	leaf_maple_2_material.set("shader_param/sway_phase_len", 8.0)

func wind_effect_enable(enable):
	var mesh = get_node("tree_maple_2")
	mesh.set_surface_material(1, leaf_maple_2_material if enable else null)