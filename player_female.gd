extends Spatial

export var player_path = "../player"
export var floor_path = "../NavigationMeshInstance/floor_demo_full/floor_demo/StaticBodyFloor"
export var rotation_speed = 0.03
export var linear_speed = 2.8

onready var female = get_node("Rotation_Helper/Model/female")
onready var pyramid = get_node("/root/palladium")
onready var pathfinder = $pathfinder
const ANGLE_TOLERANCE = 0.01

const CONVERSATION_RANGE = 7
const FOLLOW_RANGE = 3
const CLOSEUP_RANGE = 2
const ALIGNMENT_RANGE = 0.2

var cur_animation = null
var up_dir = Vector3(0, 1, 0)
var z_dir = Vector3(0, 0, 1)
var zero_dir = Vector3(0, 0, 0)

var path = []
var previous_path_size
var stuck_frames = 0

var exclusions = []
var pathfinder_stop_sheduled = false

enum COMPANION_STATE {REST, WALK, RUN}
var companion_state = COMPANION_STATE.REST

func _ready():
	# Should be done in escn by editing it by hand, or even in Blender
	#anim_player.get_animation("female_rest_99").set_loop(true)
	#anim_player.get_animation("female_walk_2").set_loop(true)
	exclusions.append(self)
	exclusions.append(get_node(floor_path))
	exclusions.append($Body_CollisionShape)  # looks like it is not included, but to be sure...
	exclusions.append($Feet_CollisionShape)
	var player = get_node(player_path)
	if player:
		exclusions.append(player)
		exclusions.append(player.get_node("Rotation_Helper/Camera/Gun_Fire_Points/Knife_Point/InteractArea"))
		exclusions.append(player.get_node("Rotation_Helper/Camera/Gun_Fire_Points/Knife_Point/InteractArea/Collision_Shape"))
		exclusions.append(player.get_node("Body_CollisionShape"))
		exclusions.append(player.get_node("Feet_CollisionShape"))

func get_viewpoint_vector():
	var eyepoint_pos = get_node("eyepoint").get_global_transform().origin
	eyepoint_pos.y = 0
	var viewpoint_pos = get_node("viewpoint").get_global_transform().origin
	viewpoint_pos.y = 0
	return viewpoint_pos - eyepoint_pos

func get_player_vector():
	var player = get_node(player_path)
	if not player:
		return Vector3(0, 0, 0)
	var eyepoint_pos = get_node("eyepoint").get_global_transform().origin
	eyepoint_pos.y = 0
	var player_pos = player.get_node("Rotation_Helper/Camera").get_global_transform().origin
	player_pos.y = 0
	return player_pos - eyepoint_pos

func get_angle_to_player():
	var player_vector = get_player_vector().normalized()
	if player_vector.length() == 0:
		return 0.0
	var viewpoint_vector = get_viewpoint_vector().normalized()
	var cross = viewpoint_vector.cross(player_vector)
	var clen = cross.length()
	if clen > 1.0:
		clen = 1.0
	elif clen < -1.0:
		clen = -1.0
	return rad2deg(asin(clen)) if cross.y > 0 else -rad2deg(asin(clen))

func get_rotation_angle(cur_dir, target_dir, force_forward = true):
	var c = cur_dir.normalized()
	var t = target_dir.normalized()
	var cross = c.cross(t)
#	var dot1 = cur_dir.dot(target_dir)
#	var dot2 = (-cur_dir).dot(target_dir)
#	if dot1 > 0 or force_forward:
#		return acos(dot1) if cross.y > 0 else -acos(dot1)
#	else:
#		return acos(dot2) if cross.y < 0 else -acos(dot2)
	var clen = cross.length()
	if clen > 1.0:
		clen = 1.0
	elif clen < -1.0:
		clen = -1.0
	return asin(clen) if cross.y > 0 else -asin(clen)

func follow(state, current_transform, target_position):
	var cur_dir = current_transform.basis.xform(z_dir)
#	cur_dir.y = 0
	var target_dir = target_position - current_transform.origin
	var distance = target_dir.length()
#	target_dir.y = 0
	var rotation_angle = get_rotation_angle(cur_dir, target_dir)
	state.set_linear_velocity(zero_dir)
	var step = state.get_step()
	if step > 0.01 or step < -0.01: # To prevent division by zero
		state.set_angular_velocity(up_dir * (rotation_angle / step) * rotation_speed)
	
#	if is_attacking:
#		return
	
	if distance > CONVERSATION_RANGE:
		conversation_manager.stop_conversation(get_node(player_path))
	
	if not path.empty():
		companion_state = COMPANION_STATE.WALK
		if distance <= ALIGNMENT_RANGE:
			path.pop_front()
		female.walk(get_angle_to_player())
		state.set_linear_velocity(target_dir.normalized() * linear_speed)
	elif distance > FOLLOW_RANGE:
		companion_state = COMPANION_STATE.WALK
		female.walk(get_angle_to_player())
		state.set_linear_velocity(target_dir.normalized() * linear_speed)
	elif distance > CLOSEUP_RANGE and companion_state == COMPANION_STATE.WALK:
		female.walk(get_angle_to_player())
		state.set_linear_velocity(target_dir.normalized() * linear_speed)
	else:
#		aggression_level = 0
		companion_state = COMPANION_STATE.REST
		female.look(get_angle_to_player())
		state.set_angular_velocity(zero_dir)

func can_move_without_collision(motion):
	# This condition WAS CORRECTED after switching to 3.1, see here:
	# https://github.com/godotengine/godot/issues/21212
	return motion[0] == 1.0 and motion[1] == 1.0

func check_obstacle(state, current_transform, player_position):
	var current_position = current_transform.origin
	var space_state = state.get_space_state()
	var param = PhysicsShapeQueryParameters.new()
	param.collision_mask = self.collision_mask
	param.set_shape($Body_CollisionShape.shape)
	param.transform = current_transform
	param.exclude = exclusions
	param.margin = 0.6  # Set to the same value as the agent radius in the navigation mesh
	var mov_vec = player_position - current_position
#	mov_vec.y = 0
	var close_to_player = mov_vec.length() < CLOSEUP_RANGE - ALIGNMENT_RANGE
	if not path.empty():
		var motion = space_state.cast_motion(param, mov_vec)
		if can_move_without_collision(motion) or close_to_player:
			pathfinder_stop()
		return
	var dic = space_state.get_rest_info(param)
	if dic.empty():
		pathfinder_stop()
	elif not close_to_player:
		pathfinder_stop_sheduled = false
		if pathfinder.is_stopped():
			pathfinder_start()

func _integrate_forces(state):
	var player = get_node(player_path)
	if not player:
		return
	var current_transform = get_global_transform()
	var current_position = current_transform.origin
	var player_position = player.get_global_transform().origin
	check_obstacle(state, current_transform, player_position)
	var target_position = path.front() if path.size() > 0 else player_position
	follow(state, current_transform, target_position)

func get_navpath(pstart, pend):
	var p1 = pyramid.get_closest_point(pstart)
	var p2 = pyramid.get_closest_point(pend)
	var p = pyramid.get_simple_path(p1, p2, true)
	return Array(p) # Vector3array too complex to use, convert to regular array

func _on_pathfinder_timeout():
	if pathfinder_stop_sheduled:
		clear_path()
		return
	if not path.empty():
		if path.size() == previous_path_size:
			stuck_frames = stuck_frames + 1
			if stuck_frames > 3:
				clear_path()
		else:
			previous_path_size = path.size()
		pathfinder.start()
		return
	var current_transform = get_global_transform()
	var current_position = current_transform.origin
	var player_position = get_node(player_path).get_global_transform().origin
	var mov_vec = player_position - current_position
	mov_vec.y = 0
#	if mov_vec.length() > SAFE_RANGE:
#		clear_path()
#		return
	path = get_navpath(get_global_transform().origin, get_node(player_path).get_global_transform().origin)
	previous_path_size = path.size()
	stuck_frames = 0
	#draw_path()
	pathfinder.start()

func draw_path():
	for ch in pyramid.get_node("path_holder").get_children():
		pyramid.get_node("path_holder").remove_child(ch)
	var k = 1.0
	for p in path:
		var m = MeshInstance.new()
		m.mesh = SphereMesh.new()
		m.mesh.radius = 0.1 * k
		k = k + 0.1
		pyramid.get_node("path_holder").add_child(m)
		m.global_translate(p)

func pathfinder_start():
	pathfinder_stop_sheduled = false
	_on_pathfinder_timeout()

func pathfinder_stop():
	pathfinder_stop_sheduled = true
	_on_pathfinder_timeout()

func clear_path():
	for ch in pyramid.get_node("path_holder").get_children():
		pyramid.get_node("path_holder").remove_child(ch)
	path.clear()
	previous_path_size = 0
	stuck_frames = 0

func use(player_node):
	if conversation_manager.conversation_active:
		conversation_manager.stop_conversation(get_node(player_path))
	elif not player_node.inventory.visible:
		conversation_manager.start_conversation(get_node(player_path), "ink-scripts/Conversation.ink.json")
	else: # player_node.inventory.visible:
		var item = player_node.get_active_item()
		if item and item.nam == "saffron_bun":
			player_node.inventory.visible = false
			item.remove()
			conversation_manager.start_conversation(get_node(player_path), "ink-scripts/Bun.ink.json")

func _unhandled_input(event):
	var player = get_node(player_path)
	if not player:
		return
	var conversation = player.get_node("HUD/Conversation")
	if conversation.is_visible_in_tree() and event is InputEventKey:
		var story = conversation.get_node('StoryNode')
		if story.CanChoose() and event.is_pressed() and event.scancode == KEY_1:
			conversation_manager.story_choose(player, 0)
		elif story.CanChoose() and event.is_pressed() and event.scancode == KEY_2:
			conversation_manager.story_choose(player, 1)
		elif story.CanChoose() and event.is_pressed() and event.scancode == KEY_3:
			conversation_manager.story_choose(player, 2)
		elif story.CanChoose() and event.is_pressed() and event.scancode == KEY_4:
			conversation_manager.story_choose(player, 3)
		elif story.CanChoose() and event.is_pressed() and event.scancode == KEY_5:
			conversation_manager.story_choose(player, 4)
		elif story.CanChoose() and event.is_pressed() and event.scancode == KEY_6:
			conversation_manager.story_choose(player, 5)
		elif story.CanChoose() and event.is_pressed() and event.scancode == KEY_7:
			conversation_manager.story_choose(player, 6)
		elif story.CanChoose() and event.is_pressed() and event.scancode == KEY_8:
			conversation_manager.story_choose(player, 7)
		elif story.CanChoose() and event.is_pressed() and event.scancode == KEY_9:
			conversation_manager.story_choose(player, 8)

func add_highlight():
	#door_mesh.mesh.surface_set_material(surface_idx_door, null)
#	door_mesh.set_surface_material(surface_idx_door, outlined_material)
	return "E: Поговорить"

func remove_highlight():
#	door_mesh.set_surface_material(surface_idx_door, null)
	#door_mesh.mesh.surface_set_material(surface_idx_door, material)
	pass

func shadow_casting_enable(enable):
	common_utils.shadow_casting_enable(self, enable)