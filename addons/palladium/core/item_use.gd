extends Spatial

onready var item_holder_node = get_node("item_holder")

var inst
var item

func activate_item(item):
	clear_item()
	var inst = item.get_model_use_instance()
	if not inst is PLDItemInUse:
		return
	self.item = item
	self.inst = inst
	common_utils.shadow_casting_enable(inst, false)
	item_holder_node.add_child(inst)

func clear_item():
	for ch in item_holder_node.get_children():
		ch.queue_free()
	item = null
	inst = null

func action(player_node, camera_node):
	if not inst is PLDItemInUse:
		return
	inst.action(player_node, camera_node)

func walk_initiate(player_node, camera_node):
	if not inst is PLDItemInUse:
		return
	inst.walk_initiate(player_node, camera_node)

func walk_stop(player_node, camera_node):
	if not inst is PLDItemInUse:
		return
	inst.walk_stop(player_node, camera_node)

func process_rotation(player_node, camera_node):
	if not inst is PLDItemInUse:
		return
	inst.process_rotation(player_node, camera_node)