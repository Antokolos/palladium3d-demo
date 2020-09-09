extends Spatial
class_name PLDItemInUse

export(NodePath) var item_player_path
export(NodePath) var hand_player_path
export(String) var item_being_taken_anim = ""
export(String) var item_action_anim = ""
export(String) var item_walking_anim = ""
export(String) var hand_takes_item_anim = ""
export(String) var hand_action_anim = ""
export(String) var hand_walking_anim = ""

onready var item_player = get_node(item_player_path)
onready var hand_player = get_node(hand_player_path)

var is_walking = false

func _ready():
	item_player.play(item_being_taken_anim)
	hand_player.play(hand_takes_item_anim)
	hand_player.connect("animation_finished", self, "_on_hand_player_animation_finished")

func action(player_node, camera_node):
	item_player.play(item_action_anim)
	hand_player.play(hand_action_anim)

func walk_initiate():
	if is_walking:
		return
	is_walking = true
	if item_walking_anim and not item_walking_anim.empty():
		item_player.play(item_walking_anim)
	if hand_walking_anim and not hand_walking_anim.empty():
		hand_player.play(hand_walking_anim)

func walk_stop():
	if not is_walking:
		return
	is_walking = false

func _on_hand_player_animation_finished(anim_name):
	pass