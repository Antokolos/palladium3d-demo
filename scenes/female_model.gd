extends PLDPlayerModel
class_name FemaleModel

const FEMALE_CUTSCENE_STAND_UP_STUMP = 1
const FEMALE_CUTSCENE_TAKES_APATA = 2
const FEMALE_CUTSCENE_SHAKES_HAND = 3
const FEMALE_CUTSCENE_KISS = 4

func _ready():
	game_state.connect("item_taken", self, "_on_item_taken")

func _on_item_taken(takable_id, count_total, count_taken, item_path):
	var apata_trap = game_state.get_activatable(DB.ActivatableIds.APATA_TRAP)
	if main_skeleton == "Female_palladium_armature" and apata_trap and apata_trap.is_untouched(): # Apply only to female model and only when the trap is still armed
		if takable_id == DB.TakableIds.APATA:
			var att = get_node("Female_palladium_armature/RightHandAttachment/Position3D")
			var item = load("res://assets/statue_4.escn").instance() #load(game_state.ITEMS[item_id].model_path).instance()
			item.set_scale(Vector3(8, 8, 8))
			att.add_child(item)

func remove_item_from_hand():
	var att = get_node("Female_palladium_armature/RightHandAttachment/Position3D")
	for ch in att.get_children():
		att.remove_child(ch)
		ch.queue_free()