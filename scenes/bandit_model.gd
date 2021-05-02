extends PLDPlayerModel
class_name BanditModel

const BANDIT_CUTSCENE_PUSHES_CHEST_START = 1
const BANDIT_CUTSCENE_POINTS_CEILING = 2
const BANDIT_CUTSCENE_GRABS_GUN = 3
const BANDIT_CUTSCENE_SHOOTS = 4
const BANDIT_CUTSCENE_SHOOTS_NEW = 5
const BANDIT_CUTSCENE_HANDSHAKE = 6
const BANDIT_CUTSCENE_HARP_INJURY = 7

const TRANSITION_NORMAL = 0
const TRANSITION_WITH_GUN = 1

onready var pistol = get_node("Bandit_armature/PistolAttachment/Position3D/beretta")

func _ready():
	conversation_manager.connect("conversation_finished", self, "_on_conversation_finished")

func attack(attack_anim_idx = -1):
	if .attack(attack_anim_idx):
		pistol.shoot()

func restore_state():
	if conversation_manager.conversation_is_finished("136_What_is_that_noise") \
		and conversation_manager.conversation_is_not_finished("146_Ugly_mug"):
		take_gun()
	else:
		remove_gun()

func _on_conversation_finished(player, conversation_name, target, initiator, last_result):
	match conversation_name:
		"136_What_is_that_noise":
			take_gun()
		"146_Ugly_mug":
			remove_gun()

func take_gun():
	play_cutscene(BANDIT_CUTSCENE_GRABS_GUN)
	$AnimationTree.set("parameters/LookTypeTransition/current", TRANSITION_WITH_GUN)
	$AnimationTree.set("parameters/WalkTypeTransition/current", TRANSITION_WITH_GUN)
	var pt = $PistolTimer
	pt.start()
	yield(pt, "timeout")
	pistol.visible = true

func remove_gun():
	$AnimationTree.set("parameters/LookTypeTransition/current", TRANSITION_NORMAL)
	$AnimationTree.set("parameters/WalkTypeTransition/current", TRANSITION_NORMAL)
	pistol.visible = false