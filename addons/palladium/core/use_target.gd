extends PLDUsable
class_name PLDUseTarget

signal use_use_target(player_node, use_target, item, result)

export(PLDDB.UseTargetIds) var use_target_id = PLDDB.UseTargetIds.NONE
export var remove_on_use = true
export var remove_all_items = false
export var matched_item_names : PoolStringArray = PoolStringArray()

func connect_signals(target):
	.connect_signals(target)
	connect("use_use_target", target, "use_use_target")

func use(player_node, camera_node):
	var hud = game_state.get_hud()
	if hud and hud.get_active_item():
		var item = hud.get_active_item()
		if not item_match(item):
			cannot_use_action(player_node, item)
			return
		hud.inventory.visible = false
		item.used(player_node, self)
		var result = use_action(player_node, item)
		if result and remove_on_use:
			item.remove(remove_all_items)
		post_use_action(player_node, item, result)
		emit_signal("use_use_target", player_node, self, item, result)

func cannot_use_action(player_node, item):
	return true

func use_action(player_node, item):
	return true

func post_use_action(player_node, item, result):
	pass

func item_match(item):
	if not item:
		return false
	for item_name in matched_item_names:
		if item_name == DB.get_item_name(item.item_id):
			return true
	return false

func get_usage_code(player_node):
	var hud = game_state.get_hud()
	if hud and hud.get_active_item():
		var item = hud.get_active_item()
		if item_match(item):
			return get_use_action_code(player_node, item)
	return ""

func get_use_action_code(player_node, item):
	return "ACTION_USE"
