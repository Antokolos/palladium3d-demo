extends PLDUseTarget

onready var palladium_fake = get_node("../postament_armature/Palladium_fake")
onready var palladium_real = get_node("../postament_armature/Palladium_real")
onready var postament_anim_player = get_node("../postament_armature/AnimationPlayer")
onready var hatch_anim_player = get_node("../Armature034/AnimationPlayer")
onready var player_pedestal = $PlayerPedestal
onready var player_hatch = $PlayerHatch
onready var player_processing = $PlayerProcessing

func _ready():
	postament_anim_player.connect("animation_finished", self, "_on_postament_animation_finished")
	player_processing.connect("finished", self, "_on_player_processing_finished")
	postament_anim_player.play("postament_180")
	hatch_anim_player.play("Armature.034Action")

func can_take_palladium():
	return palladium_real.visible \
		and not player_pedestal.is_playing() \
		and not player_processing.is_playing()

func use(player_node, camera_node):
	if not can_take_palladium():
		.use(player_node, camera_node)
		return
	palladium_real.visible = false
	game_state.take(DB.TakableIds.PALLADIUM)

func use_action(player_node, item):
	palladium_fake.visible = true
	postament_anim_player.play("postament_moves_down")
	player_pedestal.play()
	return true

func add_highlight(player_node):
	var h = .add_highlight(player_node)
	if not h.empty():
		return h
	return ("E: " + tr("ACTION_TAKE")) if can_take_palladium() else ""

func _on_postament_animation_finished(anim_name):
	if anim_name == "postament_moves_down":
		if palladium_fake.visible:
			hatch_anim_player.play_backwards("Armature.034Action")
			player_hatch.play()
			player_processing.play()
			palladium_fake.visible = false

func _on_player_processing_finished():
	palladium_real.visible = true
	hatch_anim_player.play("Armature.034Action")
	postament_anim_player.play_backwards("postament_moves_down")
	player_pedestal.play()