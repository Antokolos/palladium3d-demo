extends PLDActivatable

const SPEED_DOWN = 0.6

onready var damage_area = $DamageArea
onready var chest_shape = $DamageArea/ChestShape
onready var ceiling_sound_1 = $StaticBody/CeilingSound1
onready var ceiling_sound_2 = $StaticBody/CeilingSound2
onready var ceiling_sound_3 = $StaticBody/CeilingSound3
onready var ceiling_sound_4 = $StaticBody/CeilingSound4
onready var ceiling_sound_5 = $StaticBody/CeilingSound5

var spikes_injury_rate = 2
var does_damage = false

func _ready():
	conversation_manager.connect("conversation_finished", self, "_on_conversation_finished")

func ceiling_sound_play():
	ceiling_sound_1.play()
	ceiling_sound_2.play()
	ceiling_sound_3.play()
	ceiling_sound_4.play()
	ceiling_sound_5.play()

func ceiling_sound_stop():
	ceiling_sound_1.stop()
	ceiling_sound_2.stop()
	ceiling_sound_3.stop()
	ceiling_sound_4.stop()
	ceiling_sound_5.stop()

func get_ceiling_speed():
	# Move the ceiling faster if the player decides to move the chest
	return SPEED_DOWN if game_state.story_vars.apata_chest_rigid == 0 else 3 * SPEED_DOWN

func activate_partial():
	activate()
	$PartialActivationTimer.start()

func activate(and_change_state = true, is_restoring = false):
	.activate(and_change_state, is_restoring)
	var speed = get_ceiling_speed()
	get_node("ceiling_armat000/AnimationPlayer").play("ceiling_action.000", -1, speed)
	get_node("AnimationPlayer").play("CollisionAnim", -1, speed)
	ceiling_sound_play()

func pause(and_change_state = true, is_restoring = false):
	.pause(and_change_state, is_restoring)
	get_node("ceiling_armat000/AnimationPlayer").stop(false)
	get_node("AnimationPlayer").stop(false)
	ceiling_sound_stop()

func deactivate_forever(and_change_state = true, is_restoring = false):
	if not is_final_destination():
		var speed = get_ceiling_speed()
		get_node("ceiling_armat000/AnimationPlayer").play("ceiling_action.000", -1, -speed, true)
		get_node("AnimationPlayer").play("CollisionAnim", -1, -speed, true)
		ceiling_sound_play()
	.deactivate_forever(and_change_state, is_restoring)

func restore_state():
	if is_activated():
		activate(false)
	elif is_paused():
		activate(false)
		get_node("ceiling_armat000/AnimationPlayer").seek(20, true)
		get_node("AnimationPlayer").seek(20, true)
		pause(false)
	else:
		.restore_state()

func _on_AnimationPlayer_animation_finished(anim_name):
	if is_deactivated():
		ceiling_sound_stop()
		if ( \
			conversation_manager.conversation_is_finished("010-2-3_CeilingUp") \
			or conversation_manager.conversation_is_in_progress("010-2-3_CeilingUp")
		):
			conversation_manager.start_area_conversation("010-2-4_ApataDoneMax")
	elif is_activated():
		if conversation_manager.conversation_is_finished("010-2-1_ChestMoved"):
			var bandit = game_state.get_character(CHARS.BANDIT_NAME_HINT)
			var female = game_state.get_character(CHARS.FEMALE_NAME_HINT)
			bandit.join_party()
			female.join_party()
			ceiling_sound_stop()
			conversation_manager.start_area_conversation("010-2-2_CeilingStopped")
		else:
			# Instantly kills the player if the ceiling is at its lowest point
			game_state.kill_party()

func _on_conversation_finished(player, conversation_name, target, initiator, last_result):
	match conversation_name:
		"010-2-2_CeilingStopped":
			$DeactivationTimer.start()

func _on_DeactivationTimer_timeout():
	deactivate_forever()
	conversation_manager.start_area_conversation("010-2-3_CeilingUp")

func _physics_process(delta):
	if not game_state.is_level_ready():
		return
	chest_shape.disabled = game_state.story_vars.apata_chest_rigid != 0
	if not is_activated():
		does_damage = false
		return
	for body in damage_area.get_overlapping_bodies():
		if body.is_in_group("party"):
			does_damage = true
			return
	does_damage = false

func _on_DamageTimer_timeout():
	if does_damage:
		game_state.damage_party(spikes_injury_rate)

func _on_PartialActivationTimer_timeout():
	pause()
