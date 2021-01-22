extends PLDUseTarget

const STATE_INIT = 0
const STATE_READY = 1
const STATE_MOVING_DOWN = 2
const STATE_MOVED_DOWN = 3
const STATE_PREPARING_REAL = 4
const STATE_MOVING_UP_REAL = 5
const STATE_MOVED_UP_REAL = 6
const STATE_FINISHED_REAL = 7
const STATE_MOVING_UP_FAKE = 8
const STATE_MOVED_UP_FAKE = 9
const STATE_FINISHED_FAKE = 10
const STATE_FINISHED_EMPTY = 11

onready var palladium_fake = get_node("../postament_armature/Palladium_fake")
onready var palladium_real = get_node("../postament_armature/Palladium_real")
onready var postament_anim_player = get_node("../postament_armature/AnimationPlayer")
onready var hatch_anim_player = get_node("../Armature034/AnimationPlayer")
onready var player_pedestal = $PlayerPedestal
onready var player_hatch = $PlayerHatch
onready var player_processing = $PlayerProcessing
onready var player_palladium = $PlayerPalladium

var state = STATE_INIT
var already_rotated = false

func _ready():
	postament_anim_player.connect("animation_finished", self, "_on_postament_animation_finished")
	conversation_manager.connect("conversation_finished", self, "_on_conversation_finished")
	player_palladium.connect("finished", self, "_on_player_palladium_finished")

func can_take_palladium():
	return (
		(palladium_real.visible or palladium_fake.visible) \
		and not player_pedestal.is_playing() \
		and not player_processing.is_playing()
	)

func use(player_node, camera_node):
	if state != STATE_READY \
		and state != STATE_MOVED_UP_REAL \
		and state != STATE_MOVED_UP_FAKE:
		return
	if not can_take_palladium():
		.use(player_node, camera_node)
		return
	if palladium_real.visible:
		palladium_real.visible = false
		game_state.take(DB.TakableIds.PALLADIUM)
		common_utils.set_achievement("ANCIENT_TREASURE")
		set_state(STATE_FINISHED_REAL)
	elif palladium_fake.visible:
		palladium_fake.visible = false
		game_state.take(DB.TakableIds.ATHENA)
		set_state(STATE_FINISHED_FAKE)
	emit_signal("use_usable", player_node, self)

func use_action(player_node, item):
	set_state(STATE_MOVING_DOWN)
	return true

func add_highlight(player_node):
	if state != STATE_READY \
		and state != STATE_MOVED_UP_REAL \
		and state != STATE_MOVED_UP_FAKE:
		return ""
	var h = .add_highlight(player_node)
	if not h.empty():
		return h
	return ("E: " + tr("ACTION_TAKE")) if can_take_palladium() else ""

func _on_conversation_finished(player, conversation_name, target, initiator, last_result):
	match conversation_name:
		"174-1_Are_you_alright":
			set_state(STATE_READY)
		"175-1-1_Spikes_are_back":
			if state == STATE_INIT or state == STATE_READY:
				set_state(STATE_FINISHED_EMPTY)
		"175-4_Andreas_thanks":
			set_state(STATE_PREPARING_REAL)
		"175-4-1_Strange_sound":
			if state != STATE_MOVED_UP_REAL:
				return
			conversation_manager.start_area_conversation("175-5_Palladium")

func _on_postament_animation_finished(anim_name):
	if anim_name == "postament_180":
		already_rotated = true
		conversation_manager.start_area_conversation("175_Andreas_what_is_that_sound")
	elif anim_name == "postament_moves_down":
		already_rotated = true
		match state:
			STATE_MOVING_DOWN:
				set_state(STATE_MOVED_DOWN)
			STATE_MOVING_UP_REAL:
				set_state(STATE_MOVED_UP_REAL)
			STATE_MOVING_UP_FAKE:
				set_state(STATE_MOVED_UP_FAKE)

func _on_player_palladium_finished():
	set_state(STATE_MOVING_UP_REAL)

func return_fake_palladium():
	if game_state.has_item(DB.TakableIds.ATHENA) \
		or game_state.has_item(DB.TakableIds.PALLADIUM):
		return
	if state == STATE_MOVED_DOWN:
		set_state(STATE_MOVING_UP_FAKE)

func rotate_postament():
	if already_rotated:
		return
	player_pedestal.play()
	postament_anim_player.play("postament_180")
	hatch_anim_player.play("Armature.034Action")

func set_state(new_state):
	state = new_state
	game_state.set_multistate_state(get_path(), new_state)
	match state:
		STATE_READY:
			rotate_postament()
		STATE_MOVING_DOWN:
			palladium_fake.visible = true
			postament_anim_player.play("postament_moves_down")
			player_pedestal.play()
		STATE_MOVED_DOWN:
			hatch_anim_player.play_backwards("Armature.034Action")
			player_hatch.play()
			player_processing.play()
		STATE_PREPARING_REAL:
			player_palladium.play()
			conversation_manager.start_area_conversation("175-4-1_Strange_sound")
		STATE_MOVING_UP_REAL, STATE_MOVING_UP_FAKE:
			palladium_real.visible = (state == STATE_MOVING_UP_REAL)
			palladium_fake.visible = (state == STATE_MOVING_UP_FAKE)
			hatch_anim_player.play("Armature.034Action")
			postament_anim_player.play_backwards("postament_moves_down")
			player_pedestal.play()
		STATE_MOVED_UP_REAL, STATE_MOVED_UP_FAKE:
			palladium_real.visible = (state == STATE_MOVED_UP_REAL)
			palladium_fake.visible = (state == STATE_MOVED_UP_FAKE)
			rotate_postament()
			if palladium_real.visible:
				conversation_manager.start_area_conversation("175-5_Palladium")
		STATE_FINISHED_REAL, STATE_FINISHED_FAKE, STATE_FINISHED_EMPTY:
			rotate_postament()

func restore_state():
	set_state(game_state.get_multistate_state(get_path()))