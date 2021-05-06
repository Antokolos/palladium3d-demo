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
	var minotaur_labyrinth = game_state.get_room_enabler(DB.RoomIds.MINOTAUR_LABYRINTH)
	if minotaur_labyrinth:
		minotaur_labyrinth.connect("player_entered_room", self, "_on_player_entered_room")
		minotaur_labyrinth.connect("player_left_room", self, "_on_player_left_room")

func attack(attack_anim_idx = -1):
	var ammo_count = game_state.get_item_count(DB.TakableIds.BERETTA_AMMO)
	if ammo_count <= 0:
		return
	var attack_cutscene_id = .attack(
		attack_anim_idx if ammo_count > 1 else BANDIT_CUTSCENE_SHOOTS
	)
	if attack_cutscene_id > 0:
		pistol.shoot()
		var ad = 2 if attack_cutscene_id == BANDIT_CUTSCENE_SHOOTS_NEW else 1
		game_state.remove(DB.TakableIds.BERETTA_AMMO, ad)
		if ammo_count - ad <= 0:
			remove_gun()

func restore_state():
	if conversation_manager.conversation_is_finished("136_What_is_that_noise") \
		and game_state.get_item_count(DB.TakableIds.BERETTA_AMMO) > 0:
		take_gun()
	else:
		remove_gun()

func _on_conversation_finished(player, conversation_name, target, initiator, last_result):
	match conversation_name:
		"136_What_is_that_noise":
			if not game_state.has_item(DB.TakableIds.BERETTA_AMMO):
				game_state.take(DB.TakableIds.BERETTA_AMMO, 10)
			take_gun()

func _on_player_entered_room(room_id):
	if room_id == DB.RoomIds.MINOTAUR_LABYRINTH:
		restore_state()

func _on_player_left_room(room_id):
	if room_id == DB.RoomIds.MINOTAUR_LABYRINTH:
		remove_gun()

func take_gun():
	if pistol.visible:
		return
	play_cutscene(BANDIT_CUTSCENE_GRABS_GUN)
	$AnimationTree.set("parameters/LookTypeTransition/current", TRANSITION_WITH_GUN)
	$AnimationTree.set("parameters/WalkTypeTransition/current", TRANSITION_WITH_GUN)
	var pt = $PistolTimer
	pt.start()
	yield(pt, "timeout")
	pistol.visible = true

func remove_gun():
	if not pistol.visible:
		return
	$AnimationTree.set("parameters/LookTypeTransition/current", TRANSITION_NORMAL)
	$AnimationTree.set("parameters/WalkTypeTransition/current", TRANSITION_NORMAL)
	pistol.visible = false