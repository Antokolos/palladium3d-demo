extends PLDUseTarget

onready var anim_player = get_node("turtle/Armature/AnimationPlayer")

func _ready():
	#anim_player.get_animation("turtle_rest.001").set_loop(true)
	if game_state.has_item(DB.TakableIds.TUBE_BREATH):
		anim_player.play("turtle_rest.001")
		$CollisionShapeLying.disabled = true
	else:
		anim_player.play("turtle_lie_down_head_up")

func use_action(player_node, item):
	anim_player.play_backwards("turtle_lie_down")
	$CollisionShapeLying.disabled = true
	yield(anim_player, "animation_finished")
	anim_player.play("turtle_rest.001")
	return true

func get_use_action_code(player_node, item):
	return "ACTION_FEED_TURTLE"
