extends PLDActivatable

onready var pl1 = get_node("last_trap_floor/Armature032/AnimationPlayer")
onready var pl2 = get_node("last_trap_floor/Armature031/AnimationPlayer")
onready var collision = $CollisionShape

func activate(and_change_state = true, is_restoring = false):
	.activate(and_change_state, is_restoring)
	pl1.play("last_trap_tile_1", -1, PLDGameState.SPEED_SCALE_INFINITY if is_restoring else 1.0)
	pl2.play("last_trap_tile_2", -1, PLDGameState.SPEED_SCALE_INFINITY if is_restoring else 1.0)
	collision.disabled = true
	if not is_restoring:
		MEDIA.play_sound(MEDIA.SoundId.FEMALE_SCREAM_SHORT)
		MEDIA.change_music_to(PLDDBMedia.MusicId.FINAL_TRAP, false)

func deactivate(and_change_state = true, is_restoring = false):
	.deactivate(and_change_state, is_restoring)
	pl1.play("last_trap_tile_1", -1, -PLDGameState.SPEED_SCALE_INFINITY if is_restoring else -1.0, true)
	pl2.play("last_trap_tile_2", -1, -PLDGameState.SPEED_SCALE_INFINITY if is_restoring else -1.0, true)
	collision.disabled = false