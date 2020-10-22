extends Spatial

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
	restore_state()

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

func is_active():
	return game_state.story_vars.apata_trap_stage == PLDGameState.TrapStages.ACTIVE

func get_ceiling_speed():
	# Move the ceiling faster if the player decides to move the chest
	return SPEED_DOWN if game_state.story_vars.apata_chest_rigid == 0 else 3 * SPEED_DOWN

func activate_partial():
	activate()
	$PartialActivationTimer.start()

func activate():
	game_state.story_vars.apata_trap_stage = PLDGameState.TrapStages.ACTIVE
	var speed = get_ceiling_speed()
	get_node("ceiling_armat000/AnimationPlayer").play("ceiling_action.000", -1, speed)
	get_node("AnimationPlayer").play("CollisionAnim", -1, speed)
	ceiling_sound_play()

func pause():
	game_state.story_vars.apata_trap_stage = PLDGameState.TrapStages.PAUSED
	get_node("ceiling_armat000/AnimationPlayer").stop(false)
	get_node("AnimationPlayer").stop(false)
	ceiling_sound_stop()

func deactivate():
	game_state.story_vars.apata_trap_stage = PLDGameState.TrapStages.DISABLED
	var speed = get_ceiling_speed()
	get_node("ceiling_armat000/AnimationPlayer").play("ceiling_action.000", -1, -speed, true)
	get_node("AnimationPlayer").play("CollisionAnim", -1, -speed, true)
	ceiling_sound_play()

func restore_state():
	if is_active():
		activate()
	elif game_state.story_vars.apata_trap_stage == PLDGameState.TrapStages.PAUSED:
		activate()
		get_node("ceiling_armat000/AnimationPlayer").seek(20, true)
		get_node("AnimationPlayer").seek(20, true)
		pause()

func _on_AnimationPlayer_animation_finished(anim_name):
	if game_state.story_vars.apata_trap_stage == PLDGameState.TrapStages.DISABLED:
		ceiling_sound_stop()
		if ( \
			conversation_manager.conversation_is_finished("010-2-3_CeilingUp") \
			or conversation_manager.conversation_is_in_progress("010-2-3_CeilingUp")
		):
			conversation_manager.start_area_conversation("010-2-4_ApataDoneMax")
	elif game_state.story_vars.apata_trap_stage == PLDGameState.TrapStages.ACTIVE:
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
	deactivate()
	conversation_manager.start_area_conversation("010-2-3_CeilingUp")

func _physics_process(delta):
	chest_shape.disabled = game_state.story_vars.apata_chest_rigid != 0
	if not is_active():
		does_damage = false
		return
	for body in damage_area.get_overlapping_bodies():
		if body.is_in_group("party"):
			does_damage = true
			return
	does_damage = false

func _on_DamageTimer_timeout():
	if does_damage:
		game_state.set_health(CHARS.PLAYER_NAME_HINT, game_state.player_health_current - spikes_injury_rate, game_state.player_health_max)

func _on_PartialActivationTimer_timeout():
	pause()
