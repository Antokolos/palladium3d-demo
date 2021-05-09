extends PLDUsable
class_name PLDButtonActivator

signal use_button_activator(player_node, button_activator)

export(PLDDB.ButtonActivatorIds) var activator_id = PLDDB.ButtonActivatorIds.NONE
export var animation_player_path = "../apple_button_armature/AnimationPlayer"
export var anim_name = "apple_button_armatureAction"

onready var animation_player = get_node(animation_player_path)

func connect_signals(target):
	connect("use_button_activator", target, "use_button_activator")

func use(player_node, camera_node):
	emit_signal("use_button_activator", player_node, self)
	if animation_player.is_playing():
		return
	animation_player.play(anim_name)

func get_usage_code(player_node):
	return "ACTION_PUSH"
