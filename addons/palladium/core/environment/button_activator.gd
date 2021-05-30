extends PLDUsable
class_name PLDButtonActivator

signal use_button_activator(player_node, button_activator)

export(PLDDB.ButtonActivatorIds) var activator_id = PLDDB.ButtonActivatorIds.NONE
export var animation_player_path = "../apple_button_armature/AnimationPlayer"
export var anim_name = "apple_button_armatureAction"
export(NodePath) var path_sound_player = null

onready var animation_player = get_node(animation_player_path)
onready var sound_player = get_node(path_sound_player) if path_sound_player and has_node(path_sound_player) else null

func connect_signals(target):
	connect("use_button_activator", target, "use_button_activator")

func use(player_node, camera_node):
	emit_signal("use_button_activator", player_node, self)
	if animation_player.is_playing():
		return
	animation_player.play(anim_name)
	if not sound_player or sound_player.is_playing():
		return
	sound_player.play()

func get_usage_code(player_node):
	return "ACTION_PUSH"
