extends PLDItemContainer
class_name ApataChest

signal was_translated(chest)

const TRANSLATE_OFFSET = Vector3(0, 0, -2)

func _ready():
	restore_state()

func open(with_sound = true, speed_scale = 0.4):
	.open(with_sound, speed_scale)
	if with_sound:
		$SoundChestOpen.play()

func close(with_sound = true, speed_scale = 0.4):
	.close(with_sound, speed_scale)
	if with_sound:
		$SoundChestClose.play()

func _on_base_animation_finished(anim_name):
	if anim_name == "chest_push":
		$SoundChestMove.stop()
		do_translate()

func do_push():
	animation_player.play("chest_lid_push")
	animation_player_base.play("chest_push")
	$SoundChestMove.play()

func do_translate():
	# seek(1), because actual animation starts from second one...
	animation_player.seek(1, true)
	animation_player.stop()
	animation_player_base.seek(1, true)
	animation_player_base.stop()
	translate(TRANSLATE_OFFSET)
	emit_signal("was_translated", self)

#func _physics_process(delta):
#	if game_params.story_vars.apata_chest_rigid > 0 and mode != RigidBody.MODE_RIGID:
#		set_mode(RigidBody.MODE_RIGID)
#	elif game_params.story_vars.apata_chest_rigid <= 0 and mode != RigidBody.MODE_STATIC:
#		set_mode(RigidBody.MODE_STATIC)

func restore_state():
	.restore_state()
	if game_params.story_vars.apata_chest_rigid < 0:
		translate(TRANSLATE_OFFSET)