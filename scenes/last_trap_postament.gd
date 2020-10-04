extends PLDUseTarget

const STATE_INIT = 0
const STATE_READY = 1
const STATE_MOVING_DOWN = 2
const STATE_MOVED_DOWN = 3
const STATE_MOVING_UP = 4
const STATE_MOVED_UP = 5
const STATE_FINISHED = 6

onready var palladium_fake = get_node("../postament_armature/Palladium_fake")
onready var palladium_real = get_node("../postament_armature/Palladium_real")
onready var postament_anim_player = get_node("../postament_armature/AnimationPlayer")
onready var hatch_anim_player = get_node("../Armature034/AnimationPlayer")
onready var player_pedestal = $PlayerPedestal
onready var player_hatch = $PlayerHatch
onready var player_processing = $PlayerProcessing
onready var player_palladium = $PlayerPalladium

var state = STATE_INIT

func _ready():
	postament_anim_player.connect("animation_finished", self, "_on_postament_animation_finished")
	conversation_manager.connect("conversation_finished", self, "_on_conversation_finished")
	player_palladium.connect("finished", self, "_on_player_palladium_finished")
	restore_state()

func can_take_palladium():
	return (
		(palladium_real.visible or palladium_fake.visible) \
		and not player_pedestal.is_playing() \
		and not player_processing.is_playing()
	)

func use(player_node, camera_node):
	if state != STATE_READY and state != STATE_MOVED_UP:
		return
	if not can_take_palladium():
		.use(player_node, camera_node)
		return
	if palladium_real.visible:
		palladium_real.visible = false
		game_state.take(DB.TakableIds.PALLADIUM)
	elif palladium_fake.visible:
		palladium_fake.visible = false
		game_state.take(DB.TakableIds.ATHENA)
	set_state(STATE_FINISHED)
	emit_signal("use_usable", player_node, self)

func use_action(player_node, item):
	set_state(STATE_MOVING_DOWN)
	palladium_fake.visible = true
	postament_anim_player.play("postament_moves_down")
	player_pedestal.play()
	return true

func add_highlight(player_node):
	if state != STATE_READY and state != STATE_MOVED_UP:
		return ""
	var h = .add_highlight(player_node)
	if not h.empty():
		return h
	return ("E: " + tr("ACTION_TAKE")) if can_take_palladium() else ""

func _on_conversation_finished(player, conversation_name, target, initiator):
	match conversation_name:
		"174-1_Are_you_alright":
			postament_anim_player.play("postament_180")
			player_pedestal.play()
			hatch_anim_player.play("Armature.034Action")
		"175-1-1_Spikes_are_back":
			if state == STATE_INIT or state == STATE_READY:
				set_state(STATE_FINISHED)
		"175-4_Andreas_thanks":
			player_palladium.play()
			conversation_manager.start_area_conversation("175-4-1_Strange_sound")
		"175-4-1_Strange_sound":
			if state != STATE_MOVED_UP:
				return
			conversation_manager.start_area_conversation("175-5_Palladium")

func _on_postament_animation_finished(anim_name):
	if anim_name == "postament_180":
		if state != STATE_INIT:
			return
		set_state(STATE_READY)
		conversation_manager.start_area_conversation("175_Andreas_what_is_that_sound")
	elif anim_name == "postament_moves_down":
		match state:
			STATE_MOVING_DOWN:
				set_state(STATE_MOVED_DOWN)
				hatch_anim_player.play_backwards("Armature.034Action")
				player_hatch.play()
				player_processing.play()
			STATE_MOVING_UP:
				set_state(STATE_MOVED_UP)
				if conversation_manager.conversation_is_in_progress():
					return
				if palladium_real.visible:
					conversation_manager.start_area_conversation("175-5_Palladium")

func _on_player_palladium_finished():
	return_pedestal()

func return_palladium(real):
	if not palladium_real.visible and not palladium_fake.visible:
		return
	if state != STATE_MOVED_DOWN:
		return
	palladium_real.visible = real
	palladium_fake.visible = not real
	if not real:
		return_pedestal()

func return_pedestal():
	hatch_anim_player.play("Armature.034Action")
	postament_anim_player.play_backwards("postament_moves_down")
	player_pedestal.play()
	set_state(STATE_MOVING_UP)

func set_state(new_state):
	state = new_state
	game_state.set_multistate_state(get_path(), new_state)

func restore_state():
	state = game_state.get_multistate_state(get_path())