extends Spatial

onready var bark_apple_material = load("res://assets/bark_apple_shader.tres")
onready var leaf_apple_material = load("res://assets/leaf_apple_shader.tres")

func _ready():
	bark_apple_material.set("shader_param/sway_speed", 2.0)
	bark_apple_material.set("shader_param/sway_strength", 0.05)
	bark_apple_material.set("shader_param/sway_phase_len", 8.0)
	leaf_apple_material.set("shader_param/sway_speed", 2.0)
	leaf_apple_material.set("shader_param/sway_strength", 0.05)
	leaf_apple_material.set("shader_param/sway_phase_len", 8.0)

func wind_effect_enable(enable):
	var mesh = get_node("tree_apple000")
	mesh.set_surface_material(0, bark_apple_material if enable else null)
	mesh.set_surface_material(1, leaf_apple_material if enable else null)