extends PLDUsable
class_name PLDButtonActivator

signal use_button_activator(player_node, button_activator)

export(DB.ButtonActivatorIds) var activator_id = DB.ButtonActivatorIds.NONE
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

func add_highlight(player_node):
	return common_utils.get_action_input_control() + tr("ACTION_PUSH")
