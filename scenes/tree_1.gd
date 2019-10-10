extends Spatial

onready var tree_1_material = load("res://assets/tree_1_shader.tres")

func _ready():
	tree_1_material.set("shader_param/sway_speed", 2.0)
	tree_1_material.set("shader_param/sway_strength", 0.05)
	tree_1_material.set("shader_param/sway_phase_len", 8.0)

func wind_effect_enable(enable):
	var mesh = get_node("tree_1")
	mesh.set_surface_material(0, tree_1_material if enable else null)