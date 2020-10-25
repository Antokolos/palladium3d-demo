extends PLDActivatable

onready var pl1 = get_node("last_trap_floor/Armature032/AnimationPlayer")
onready var pl2 = get_node("last_trap_floor/Armature031/AnimationPlayer")
onready var collision = $CollisionShape

func activate(and_change_state = true):
	.activate(and_change_state)
	pl1.play("last_trap_tile_1")
	pl2.play("last_trap_tile_2")
	collision.disabled = true

func deactivate(and_change_state = true):
	.deactivate(and_change_state)
	pl1.play_backwards("last_trap_tile_1")
	pl2.play_backwards("last_trap_tile_2")
	collision.disabled = false