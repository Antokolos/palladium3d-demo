extends Spatial

const MAX_SIZE = Vector3(1.0, 1.0, 1.0)
const AXIS_VALUE_THRESHOLD = 0.15
var KEY_LOOK_SPEED_FACTOR = 30
var MOUSE_SENSITIVITY = 0.1
onready var item_holder_node = get_node("item_holder")

var hud
var flashlight
var flashlight_visible
var custom_actions = []
var inst
var item
var angle_rad_x = 0
var angle_rad_y = 0

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
		var label_close_node = hud.actions_panel.get_node("ActionsContainer/HintLabelClose")
		label_close_node.text = common_utils.get_action_key("item_preview_toggle") + tr("ACTION_CLOSE_PREVIEW")
		var custom_actions_node = hud.actions_panel.get_node("ActionsContainer/CustomActions")
		for ch in custom_actions_node.get_children():
			ch.queue_free()
		custom_actions = game_params.get_custom_actions(item)
		for act in custom_actions:
			var ch = label_close_node.duplicate(0)
			ch.text = common_utils.get_action_key(act) + tr(item.nam + "_" + act)
			custom_actions_node.add_child(ch)
		get_tree().paused = true
		hud.show_game_ui(false)
		hud.actions_panel.show()

func _input(event):
	if item_holder_node.get_child_count() > 0:
		if event.is_action_pressed("item_preview_toggle") or event.is_action_pressed("ui_tablet_toggle"):
			close_preview()
		elif game_params.execute_custom_action(event, item):
			close_preview()
		elif Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			if event is InputEventMouseMotion:
				item_holder_node.rotate_x(deg2rad(event.relative.y * MOUSE_SENSITIVITY))
				item_holder_node.rotate_y(deg2rad(event.relative.x * MOUSE_SENSITIVITY))
				angle_rad_x = 0
				angle_rad_y = 0
			elif event is InputEventJoypadMotion:
				var v = event.get_axis_value()
				var nonzero = v > AXIS_VALUE_THRESHOLD or v < -AXIS_VALUE_THRESHOLD
				if event.get_axis() == JOY_AXIS_2:  # Joypad Right Stick Horizontal Axis
					angle_rad_y = deg2rad(KEY_LOOK_SPEED_FACTOR * MOUSE_SENSITIVITY * v) if nonzero else 0
				if event.get_axis() == JOY_AXIS_3:  # Joypad Right Stick Vertical Axis
					angle_rad_x = deg2rad(KEY_LOOK_SPEED_FACTOR * MOUSE_SENSITIVITY * v) if nonzero else 0
			else:
				if event.is_action_pressed("cam_up"):
					angle_rad_x = deg2rad(KEY_LOOK_SPEED_FACTOR * MOUSE_SENSITIVITY * -1)
				elif event.is_action_pressed("cam_down"):
					angle_rad_x = deg2rad(KEY_LOOK_SPEED_FACTOR * MOUSE_SENSITIVITY)
				elif event.is_action_released("cam_up") or event.is_action_released("cam_down"):
					angle_rad_x = 0
				
				if event.is_action_pressed("cam_left"):
					angle_rad_y = deg2rad(KEY_LOOK_SPEED_FACTOR * MOUSE_SENSITIVITY * -1)
				elif event.is_action_pressed("cam_right"):
					angle_rad_y = deg2rad(KEY_LOOK_SPEED_FACTOR * MOUSE_SENSITIVITY)
				elif event.is_action_released("cam_left") or event.is_action_released("cam_right"):
					angle_rad_y = 0

func _process(delta):
	if item_holder_node.get_child_count() > 0:
		item_holder_node.rotate_x(angle_rad_x)
		item_holder_node.rotate_y(angle_rad_y)

func close_preview():
	for ch in item_holder_node.get_children():
		ch.queue_free()
	if hud:
		hud.actions_panel.hide()
		hud.show_game_ui(true)
		if game_params.get_quick_items_count() > 1:
			hud.queue_popup_message("MESSAGE_CONTROLS_ITEMS", ["N", "B"])
			hud.queue_popup_message("MESSAGE_CONTROLS_ITEMS_KEYS", ["1", "6"])
	custom_actions.clear()
	get_tree().paused = false
	if not flashlight_visible:
		flashlight.hide()
