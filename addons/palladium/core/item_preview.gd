extends Spatial

signal preview_opened(item)
signal preview_closed(item)

const MAX_SIZE = Vector3(0.5, 0.5, 0.5)
const AXIS_VALUE_THRESHOLD = 0.15
const KEY_LOOK_SPEED_FACTOR = 30
const ZOOM_MIN = Vector3(0.40001, 0.40001, 0.40001)
const ZOOM_MAX = Vector3(2.0, 2.0, 2.0)
const ZOOM_SPEED = Vector3(0.2, 0.2, 0.2)
onready var item_holder_node = get_node("item_holder")

var inst
var item
var angle_rad_x = 0
var angle_rad_y = 0
var base_scale = Vector3(1.0, 1.0, 1.0)
var zoom = Vector3(1.0, 1.0, 1.0)
var des_zoom = zoom

func _ready():
	var hud = game_state.get_hud()
	connect("preview_opened", hud, "_on_preview_opened")
	connect("preview_closed", hud, "_on_preview_closed")

func vmin(vec):
	var m = min(vec.x, vec.y)
	return min(m, vec.z)

func coord_div(vec1, vec2):
	return Vector3(vec1.x / vec2.x, vec1.y / vec2.y, vec1.z / vec2.z)

func toggle_meshes(root, enable):
	for m in root.get_children():
		if m is MeshInstance:
			m.set_layer_mask_bit(5, enable)
		else:
			toggle_meshes(m, enable)

func is_opened():
	return item_holder_node.get_child_count() > 0

func open_preview(item):
	if not item:
		return
	self.item = item
	self.inst = item.get_model_instance()
	for ch in item_holder_node.get_children():
		ch.queue_free()
	common_utils.shadow_casting_enable(inst, false)
	toggle_meshes(inst, true)
	item_holder_node.add_child(inst)
	var aabb = item.get_aabb(inst)
	var vmcd = vmin(coord_div(MAX_SIZE, aabb.size))
	base_scale = Vector3(vmcd, vmcd, vmcd)
	inst.scale_object_local(base_scale)
	zoom = Vector3(1.0, 1.0, 1.0)
	des_zoom = zoom
	emit_signal("preview_opened", item)

func _input(event):
	if item_holder_node.get_child_count() > 0 and not game_state.is_video_cutscene():
		if event.is_action_pressed("item_preview_toggle") or event.is_action_pressed("ui_tablet_toggle"):
			close_preview()
		elif event.is_action_pressed("item_preview_zoom_in"):
			if des_zoom < ZOOM_MAX:
				des_zoom += ZOOM_SPEED
		elif event.is_action_pressed("item_preview_zoom_out"):
			if des_zoom > ZOOM_MIN:
				des_zoom -= ZOOM_SPEED
		elif DB.can_execute_custom_action(item, "item_preview_action_1", event):
			close_preview()
			DB.execute_custom_action(item, "item_preview_action_1")
		elif DB.can_execute_custom_action(item, "item_preview_action_2", event):
			close_preview()
			DB.execute_custom_action(item, "item_preview_action_2")
		elif DB.can_execute_custom_action(item, "item_preview_action_3", event):
			close_preview()
			DB.execute_custom_action(item, "item_preview_action_3")
		elif DB.can_execute_custom_action(item, "item_preview_action_4", event):
			close_preview()
			DB.execute_custom_action(item, "item_preview_action_4")
		elif common_utils.is_mouse_captured():
			if event is InputEventMouseMotion:
				item_holder_node.rotate_x(deg2rad(event.relative.y * settings.get_sensitivity() * settings.get_yaxis_coeff()))
				item_holder_node.rotate_y(deg2rad(event.relative.x * settings.get_sensitivity()))
				angle_rad_x = 0
				angle_rad_y = 0
			elif event is InputEventJoypadMotion:
				var v = event.get_axis_value()
				var nonzero = v > AXIS_VALUE_THRESHOLD or v < -AXIS_VALUE_THRESHOLD
				if event.get_axis() == JOY_AXIS_2:  # Joypad Right Stick Horizontal Axis
					angle_rad_y = deg2rad(KEY_LOOK_SPEED_FACTOR * settings.get_sensitivity() * v) if nonzero else 0
				if event.get_axis() == JOY_AXIS_3:  # Joypad Right Stick Vertical Axis
					angle_rad_x = deg2rad(KEY_LOOK_SPEED_FACTOR * settings.get_sensitivity() * v * settings.get_yaxis_coeff()) if nonzero else 0
			else:
				if event.is_action_pressed("cam_up"):
					angle_rad_x = deg2rad(KEY_LOOK_SPEED_FACTOR * settings.get_sensitivity() * -1 * settings.get_yaxis_coeff())
				elif event.is_action_pressed("cam_down"):
					angle_rad_x = deg2rad(KEY_LOOK_SPEED_FACTOR * settings.get_sensitivity() * settings.get_yaxis_coeff())
				elif event.is_action_released("cam_up") or event.is_action_released("cam_down"):
					angle_rad_x = 0
				
				if event.is_action_pressed("cam_left"):
					angle_rad_y = deg2rad(KEY_LOOK_SPEED_FACTOR * settings.get_sensitivity() * -1)
				elif event.is_action_pressed("cam_right"):
					angle_rad_y = deg2rad(KEY_LOOK_SPEED_FACTOR * settings.get_sensitivity())
				elif event.is_action_released("cam_left") or event.is_action_released("cam_right"):
					angle_rad_y = 0

func _process(delta):
	if not game_state.is_level_ready():
		return
	if item_holder_node.get_child_count() > 0:
		item_holder_node.rotate_x(angle_rad_x)
		item_holder_node.rotate_y(angle_rad_y)
		if (
			zoom.x != des_zoom.x
			or zoom.y != des_zoom.y
			or zoom.z != des_zoom.z
		):
			zoom = lerp(zoom, des_zoom, 0.2)
			inst.set_scale(base_scale * zoom)

func close_preview():
	for ch in item_holder_node.get_children():
		toggle_meshes(ch, false)
		ch.queue_free()
	emit_signal("preview_closed", item)
