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

func coord_mult(vec1, vec2):
	return Vector3(vec1.x * vec2.x, vec1.y * vec2.y, vec1.z * vec2.z)

func coord_div(vec1, vec2):
	return Vector3(vec1.x / vec2.x, vec1.y / vec2.y, vec1.z / vec2.z)

func get_aabb(inst):
	if not inst is Spatial:
		return null
	var aabb = inst.get_aabb() if inst is VisualInstance else null
	for ch in inst.get_children():
		var aabb_ch = get_aabb(ch)
		if not aabb_ch:
			continue
		aabb = aabb.merge(aabb_ch) if aabb else aabb_ch
	return AABB(coord_mult(inst.scale, aabb.position), coord_mult(inst.scale, aabb.size)) if aabb else null

func open_preview(item, hud, flashlight):
	if item:
		self.item = item
		self.hud = hud
		self.flashlight = flashlight
		self.inst = item.get_model_instance()
		for ch in item_holder_node.get_children():
			ch.queue_free()
		item_holder_node.add_child(inst)
		var aabb = get_aabb(inst)
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
				ch.text = act.action_hint
				custom_actions_node.add_child(ch)
		get_tree().paused = true
		$ActionsPanel.show()

func _input(event):
	if item_holder_node.get_child_count() > 0:
		if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			item_holder_node.rotate_x(deg2rad(event.relative.y * MOUSE_SENSITIVITY))
			item_holder_node.rotate_y(deg2rad(event.relative.x * MOUSE_SENSITIVITY * -1))

func close_preview():
	for ch in item_holder_node.get_children():
		ch.queue_free()
	$ActionsPanel.hide()
	custom_actions.clear()
	get_tree().paused = false
	if not flashlight_visible:
		flashlight.hide()

func _unhandled_input(event):
	if item_holder_node.get_child_count() > 0:
		var is_key = event is InputEventKey and event.is_pressed()
		if not is_key:
			return
		var is_action = event.scancode == KEY_E
		for act in custom_actions:
			is_action = is_action or (event.scancode == act.key_code)
		if not is_action:
			return
		close_preview()
		if inst.has_method("execute_action"):
			 inst.execute_action(event.scancode, item)
