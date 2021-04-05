extends Spatial
class_name PLDItemInUse

export(NodePath) var item_player_path
export(NodePath) var hand_player_path
export(String) var item_being_taken_anim = ""
export(String) var item_rest_anim = ""
export(String) var item_action_anim = ""
export(String) var item_walking_anim = ""
export(String) var item_running_anim = ""
export(String) var hand_takes_item_anim = ""
export(String) var hand_rest_anim = ""
export(String) var hand_action_anim = ""
export(String) var hand_walking_anim = ""
export(String) var hand_running_anim = ""

onready var item_player = get_node(item_player_path) if item_player_path and has_node(item_player_path) else null
onready var hand_player = get_node(hand_player_path) if hand_player_path and has_node(hand_player_path) else null

var is_walking = false

func _ready():
	if item_player:
		do_before_item_player_animation(item_being_taken_anim)
		item_player.connect("animation_finished", self, "_on_item_player_animation_finished")
		item_player.play(item_being_taken_anim)
	if hand_player:
		do_before_hand_player_animation(hand_takes_item_anim)
		hand_player.connect("animation_finished", self, "_on_hand_player_animation_finished")
		hand_player.play(hand_takes_item_anim)

func action(player_node, camera_node):
	is_walking = false
	if item_player:
		do_before_item_player_animation(item_action_anim)
		item_player.play(item_action_anim)
	if hand_player:
		do_before_hand_player_animation(hand_action_anim)
		hand_player.play(hand_action_anim)

func walk_initiate(player_node, camera_node):
	var is_sprinting = player_node.is_sprinting()
	if is_walking:
		if is_sprinting \
			and plays_anim(item_player, item_running_anim) \
			and plays_anim(hand_player, hand_running_anim):
			return
		if not is_sprinting \
			and plays_anim(item_player, item_walking_anim) \
			and plays_anim(hand_player, hand_walking_anim):
			return
	if plays_anim(item_player, item_action_anim) or plays_anim(hand_player, hand_action_anim):
		return
	is_walking = true
	var item_anim = item_running_anim if is_sprinting else item_walking_anim
	var hand_anim = hand_running_anim if is_sprinting else hand_walking_anim
	if item_player and item_anim and not item_anim.empty():
		do_before_item_player_animation(item_anim)
		item_player.play(item_anim)
	if hand_player and hand_anim and not hand_anim.empty():
		do_before_hand_player_animation(hand_anim)
		hand_player.play(hand_anim)

func plays_anim(anim_player, anim):
	return anim \
		and not anim.empty() \
		and anim_player.is_playing() \
		and anim_player.get_current_animation() == anim

func walk_stop(player_node, camera_node):
	if not is_walking:
		return
	is_walking = false
	if item_player:
		if plays_anim(item_player, item_walking_anim) or plays_anim(item_player, item_running_anim):
			item_player.stop()
		if item_rest_anim and not item_rest_anim.empty():
			item_player.play(item_rest_anim)
	if hand_player:
		if plays_anim(hand_player, hand_walking_anim) or plays_anim(hand_player, hand_running_anim):
			hand_player.stop()
		if hand_rest_anim and not hand_rest_anim.empty():
			hand_player.play(hand_rest_anim)

func process_rotation(player_node, camera_node):
	pass

func is_walking():
	return is_walking

func do_before_hand_player_animation(anim_name):
	pass

func do_before_item_player_animation(anim_name):
	pass

func _on_item_player_animation_finished(anim_name):
	if (anim_name == item_being_taken_anim or anim_name == item_action_anim) \
		and not is_walking \
		and item_rest_anim \
		and not item_rest_anim.empty():
		item_player.play(item_rest_anim)

func _on_hand_player_animation_finished(anim_name):
	if (anim_name == hand_takes_item_anim or anim_name == hand_action_anim) \
		and not is_walking \
		and hand_rest_anim \
		and not hand_rest_anim.empty():
		hand_player.play(hand_rest_anim)