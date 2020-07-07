extends PLDUsable
class_name PLDButtonActivator

signal use_button_activator(player_node, button_activator)

enum ButtonActivatorIds {
	NONE = 0,
	ERIDA = 10,
	RIDDLE_BUTTON = 20,
	POMEGRANATE_1 = 30,
	POMEGRANATE_2 = 40,
	POMEGRANATE_3 = 50,
	POMEGRANATE_4 = 60,
	POMEGRANATE_5 = 70,
	POMEGRANATE_6 = 80,
}
export(ButtonActivatorIds) var activator_id = ButtonActivatorIds.NONE
export var animation_player_path = "../apple_button_armature/AnimationPlayer"
export var anim_name = "apple_button_armatureAction"

onready var animation_player = get_node(animation_player_path)

func connect_signals(level):
	connect("use_button_activator", level, "use_button_activator")

func use(player_node, camera_node):
	emit_signal("use_button_activator", player_node, self)
	if animation_player.is_playing():
		return
	animation_player.play(anim_name)

func add_highlight(player_node):
	return "E: " + tr("ACTION_PUSH")
