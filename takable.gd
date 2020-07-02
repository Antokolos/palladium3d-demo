extends PhysicsBody
class_name Takable

signal use_takable(player_node, takable, parent, was_taken)

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
	SPHERE_FOR_POSTAMENT = 140,
	ENVELOPE = 150,
	BARN_LOCK_KEY = 160,
	GREEK_SWORD = 170,
	LYRE_SNAKE = 180,
	LYRE_RAT = 190,
	LYRE_SPIDER = 200
}
export(TakableIds) var takable_id = TakableIds.NONE
# if exclusive == true, then this item should not be present at the same time as the another items on the same pedestal or in the same container
export var exclusive = true

onready var initially_present = visible

func _ready():
	restore_state()
	game_params.connect("item_taken", self, "_on_item_taken")
	game_params.connect("item_removed", self, "_on_item_removed")

func connect_signals(level):
	connect("use_takable", level, "use_takable")

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
		TakableIds.ENVELOPE:
			return "envelope"
		TakableIds.BARN_LOCK_KEY:
			return "barn_lock_key"
		TakableIds.GREEK_SWORD:
			return "sword_body"
		TakableIds.LYRE_RAT:
			return "lyre_rat"
		TakableIds.LYRE_SNAKE:
			return "lyre_snake"
		TakableIds.LYRE_SPIDER:
			return "lyre_spider"
		TakableIds.NONE:
			continue
		_:
			return null

func use(player_node, camera_node):
	if takable_id == TakableIds.APATA and player_node.is_player() and game_params.story_vars.apata_trap_stage == game_params.ApataTrapStages.ARMED:
		# Cannot be taken by the main player if Apata's trap has not been activated yet
		return
	var was_taken = is_present()
	game_params.take(get_item_name())
	emit_signal("use_takable", player_node, self, get_parent(), was_taken)

func _on_item_taken(nam, cnt):
	if nam == get_item_name():
		make_absent()

func _on_item_removed(nam, cnt):
	# TODO: make present??? Likely it is handled in containers...
	if has_node("SoundPut"):
		$SoundPut.play()

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
	if takable_id == TakableIds.APATA and game_params.story_vars.apata_trap_stage == game_params.ApataTrapStages.ARMED:
		return ""
	return "E: " + tr("ACTION_TAKE") if is_present() else ""

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
