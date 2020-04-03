extends ItemContainer
class_name ApataChest

signal was_translated(chest)

const TRANSLATE_OFFSET = Vector3(0, 0, -2)
const LID_PLAYER_PATH = "apatha_chest/apatha_chest_armature_lid/AnimationPlayer"
const CHEST_PLAYER_PATH = "apatha_chest/apatha_chest_armature_base/AnimationPlayer"

func _ready():
	restore_state()

func _on_animation_finished(anim_name):
	get_node(CHEST_PLAYER_PATH).disconnect("animation_finished", self, "_on_animation_finished")
	if anim_name == "chest_push":
		do_translate()

func do_push():
	var lid_player = get_node(LID_PLAYER_PATH)
	var chest_player = get_node(CHEST_PLAYER_PATH)
	lid_player.play("chest_lid_push")
	chest_player.play("chest_push")

func do_translate():
	var lid_player = get_node(LID_PLAYER_PATH)
	var chest_player = get_node(CHEST_PLAYER_PATH)
	# seek(1), because actual animation starts from second one...
	lid_player.seek(1, true)
	lid_player.stop()
	chest_player.seek(1, true)
	chest_player.stop()
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
	else:
		get_node(CHEST_PLAYER_PATH).connect("animation_finished", self, "_on_animation_finished")