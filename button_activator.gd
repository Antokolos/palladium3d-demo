extends StaticBody
class_name ButtonActivator

signal use_button_activator(player_node, button_activator)

enum ButtonActivatorIds {
	NONE = 0,
	ERIDA = 10
}
export(ButtonActivatorIds) var activator_id = ButtonActivatorIds.NONE
export var animation_player_path = "../apple_button_armature/AnimationPlayer"
export var anim_name = "apple_button_armatureAction"

onready var animation_player = get_node(animation_player_path)

func connect_signals(level):
	connect("use_button_activator", level, "use_button_activator")

func use(player_node):
	if animation_player.is_playing():
		return
	animation_player.play(anim_name)
	emit_signal("use_button_activator", player_node, self)

func add_highlight(player_node):
	return "E: Нажать"

func remove_highlight(player_node):
	pass