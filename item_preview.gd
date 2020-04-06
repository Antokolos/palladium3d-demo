extends Spatial

const MAX_SIZE = Vector3(1.0, 1.0, 1.0)
var MOUSE_SENSITIVITY = 0.1
onready var item_holder_node = get_node("item_holder")
onready var label_close_node = get_node("ActionsPanel/ActionsContainer/HintLabelClose")
onready var custom_actions_node = get_node("ActionsPanel/ActionsContainer/CustomActions")

var hud
var flashlight
var flashlight_visible
var custom_actions = []
var inst
var item

func vmin(vec):
	var m = min(vec.x, vec.y)
	return min(m, vec.z)

func coord_div(vec1, vec2):
	return Vector3(vec1.x / vec2.x, vec1.y / vec2.y, vec1.z / vec2.z)

func is_opened():
	return item_holder_node.get_child_count() > 0

func open_preview(item, hud, flashlight):
	if item:
		self.item = item
		self.hud = hud
		self.flashlight = flashlight
		self.inst = item.get_model_instance()
		for ch in item_holder_node.get_children():
			ch.queue_free()
		item_holder_node.add_child(inst)
		var aabb = item.get_aabb(inst)
		var vm = min(vmin(coord_div(MAX_SIZE, aabb.size)), MAX_SIZE.x)
		inst.scale_object_local(Vector3(vm, vm, vm))
		hud.inventory.visible = false
		#hud.dimmer.visible = true
		flashlight_visible = flashlight.is_visible_in_tree()
		flashlight.show()
		for ch in custom_actions_node.get_children():
			ch.queue_free()
		if inst.has_method("get_custom_actions"):
			custom_actions = inst.get_custom_actions()
			for act in custom_actions:
				var ch = label_close_node.duplicate(0)
				ch.text = get_action_key(act) + act.action_hint
				custom_actions_node.add_child(ch)
		get_tree().paused = true
		hud.quick_items_panel.hide()
		$ActionsPanel.show()

func get_action_key(act):
	var list = InputMap.get_action_list(act.action_event)
	for action in list:
		if action is InputEventKey:
			return action.as_text() + ": "
	return ""

func _input(event):
	if item_holder_node.get_child_count() > 0:
		if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			item_holder_node.rotate_x(deg2rad(event.relative.y * MOUSE_SENSITIVITY))
			item_holder_node.rotate_y(deg2rad(event.relative.x * MOUSE_SENSITIVITY))
		elif event.is_action_pressed("item_preview_toggle"):
			close_preview()
		elif inst.has_method("execute_action"):
			if inst.execute_action(event, item):
				close_preview()

func close_preview():
	for ch in item_holder_node.get_children():
		ch.queue_free()
	$ActionsPanel.hide()
	if hud:
		hud.quick_items_panel.show()
	custom_actions.clear()
	get_tree().paused = false
	if not flashlight_visible:
		flashlight.hide()
