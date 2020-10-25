extends PLDActivatable

onready var erida_trap_sound_1 = get_node("EridaTrapSound1")
onready var erida_trap_sound_2 = get_node("EridaTrapSound2")
onready var erida_trap_sound_3 = get_node("EridaTrapSound3")
onready var erida_trap_sound_4 = get_node("EridaTrapSound4")
onready var eris_particles = get_node("eris_particles")

func activate(and_change_state = true):
	.activate(and_change_state)
	erida_trap_sound_1.play()
	erida_trap_sound_2.play()
	erida_trap_sound_3.play()
	erida_trap_sound_4.play()
	eris_particles.emitting = true
	eris_particles.restart()
	game_state.set_poisoned(game_state.get_player(), true)

func activate_forever(and_change_state = true):
	.activate_forever(and_change_state)
	activate(and_change_state)

func deactivate(and_change_state = true):
	.deactivate(and_change_state)
	erida_trap_sound_1.stop()
	erida_trap_sound_2.stop()
	erida_trap_sound_3.stop()
	erida_trap_sound_4.stop()
	eris_particles.emitting = false
	game_state.set_poisoned(game_state.get_player(), false)

func deactivate_forever(and_change_state = true):
	.deactivate_forever(and_change_state)
	deactivate(and_change_state)

func increase_sound_volume():
	var v1 = erida_trap_sound_1.get_unit_db()
	erida_trap_sound_1.set_unit_db(v1 / 2)
	var v2 = erida_trap_sound_2.get_unit_db()
	erida_trap_sound_2.set_unit_db(v2 / 2)
	var v3 = erida_trap_sound_3.get_unit_db()
	erida_trap_sound_3.set_unit_db(v3 / 2)
	var v4 = erida_trap_sound_4.get_unit_db()
	erida_trap_sound_4.set_unit_db(v4 / 2)