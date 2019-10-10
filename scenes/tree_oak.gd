extends Spatial

onready var oak_material = load("res://assets/oak_branch_tr_shader.tres")

func _ready():
	oak_material.set("shader_param/sway_speed", 2.0)
	oak_material.set("shader_param/sway_strength", 0.05)
	oak_material.set("shader_param/sway_phase_len", 8.0)

func wind_effect_enable(enable):
	var mesh = get_node("tree_oak001")
	mesh.set_surface_material(2, oak_material if enable else null)