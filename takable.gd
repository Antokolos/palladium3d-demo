extends PhysicsBody
class_name Takable

enum TakableIds {
	NONE = 0,
	APATA = 10,
	URANIA = 20,
	CLIO = 30,
	MELPOMENE = 40,
	ARES = 50,
	HERMES = 60,
	ERIDA = 70,
	ARTEMIDA = 80,
	APHRODITE = 90,
	HEBE = 100,
	HERA = 110,
	APOLLO = 120,
	ATHENA = 130,
	SPHERE_FOR_POSTAMENT = 140
}
export(TakableIds) var takable_id = TakableIds.NONE
export var initially_present = true
export var level_path = "../../.."

# if exclusive == true, then this item should not be present at the same time as the another items on the same pedestal or in the same container
export var exclusive = true

func _ready():
	restore_state()

func get_item_name():
	match takable_id:
		TakableIds.APATA:
			return "statue_apata"
		TakableIds.URANIA:
			return "statue_urania"
		TakableIds.CLIO:
			return "statue_clio"
		TakableIds.MELPOMENE:
			return "statue_melpomene"
		TakableIds.ARES:
			return "statue_ares"
		TakableIds.HERMES:
			return "statue_hermes"
		TakableIds.ERIDA:
			return "statue_erida"
		TakableIds.ARTEMIDA:
			return "statue_artemida"
		TakableIds.APHRODITE:
			return "statue_aphrodite"
		TakableIds.HEBE:
			return "statue_hebe"
		TakableIds.HERA:
			return "hera_statue"
		TakableIds.APOLLO:
			return "statue_apollo"
		TakableIds.ATHENA:
			return "statue_athena"
		TakableIds.SPHERE_FOR_POSTAMENT:
			return "sphere_for_postament_body"
		TakableIds.NONE:
			continue
		_:
			return null

func use(player_node):
	if takable_id == TakableIds.APATA:
		match game_params.story_vars.apata_trap_stage:
			game_params.ApataTrapStages.ARMED:
				var level = get_node(level_path)
				level.get_door("door_0").close()
				level.get_node("ceiling_moving_1").activate()
				conversation_manager.start_conversation(player_node, game_params.get_companion(), "ApataTrap")
				game_params.story_vars.apata_trap_stage = game_params.ApataTrapStages.GOING_DOWN
			game_params.ApataTrapStages.GOING_DOWN:
				pass
			_:
				return
	elif takable_id == TakableIds.HERMES:
		var level = get_node(level_path)
		level.get_door("door_5").open()
		level.get_door("door_8").open()
	
	take(player_node)

func take(player_node):
	game_params.take(get_item_name())
	make_absent()
	var hud = player_node.get_hud()
	if hud:
		hud.synchronize_items()

func has_id(tid):
	return takable_id == tid

func is_exclusive():
	return exclusive

func is_present():
	var ts = game_params.get_takable_state(get_path())
	return (ts == game_params.TakableState.DEFAULT and initially_present) or (ts == game_params.TakableState.PRESENT)

func enable_collisions(enable):
	for ch in get_children():
		if ch is CollisionShape:
			ch.disabled = not enable

func make_present():
	visible = true
	enable_collisions(true)
	game_params.set_takable_state(get_path(), false)

func make_absent():
	visible = false
	enable_collisions(false)
	game_params.set_takable_state(get_path(), true)

func add_highlight(player_node):
	#door_mesh.mesh.surface_set_material(surface_idx_door, null)
#	door_mesh.set_surface_material(surface_idx_door, outlined_material)
	if takable_id == TakableIds.APATA:
		match game_params.story_vars.apata_trap_stage:
			game_params.ApataTrapStages.PAUSED:
				continue
			game_params.ApataTrapStages.DISABLED:
				return ""
	return "E: Взять" if is_present() else ""

func remove_highlight(player_node):
#	door_mesh.set_surface_material(surface_idx_door, null)
	#door_mesh.mesh.surface_set_material(surface_idx_door, material)
	pass

func restore_state():
	var state = game_params.get_takable_state(get_path())
	if state == game_params.TakableState.DEFAULT:
		if initially_present:
			make_present()
		else:
			make_absent()
		return
	if state == game_params.TakableState.PRESENT:
		make_present()
	else:
		make_absent()
