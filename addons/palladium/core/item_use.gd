extends Spatial

onready var item_holder_node = get_node("item_holder")

var inst
var item

func activate_item(item):
	clear_item()
	var inst = item.get_model_use_instance()
	if not inst is PLDItemInUse:
		return false
	self.item = item
	self.inst = inst
	common_utils.shadow_casting_enable(inst, false)
	item_holder_node.add_child(inst)
	return true

func clear_item():
	for ch in item_holder_node.get_children():
		ch.queue_free()
	item = null
	inst = null

func get_item_in_use():
	return item

func action(player_node, camera_node):
	if not inst is PLDItemInUse:
		return false
	inst.action(player_node, camera_node)
	return true

func walk_initiate(player_node, camera_node):
	if not inst is PLDItemInUse:
		return false
	inst.walk_initiate(player_node, camera_node)
	return true

func walk_stop(player_node, camera_node):
	if not inst is PLDItemInUse:
		return false
	inst.walk_stop(player_node, camera_node)
	return true

func process_rotation(player_node, camera_node):
	if not inst is PLDItemInUse:
		return false
	inst.process_rotation(player_node, camera_node)
	return true
