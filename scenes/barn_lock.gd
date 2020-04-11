extends Spatial
class_name BarnLock

const STATE_OPENED = 1

func _ready():
	restore_state()

func use(player_node):
	var hud = game_params.get_hud()
	if hud and hud.get_active_item():
		var item = hud.get_active_item()
		if not item_match(item):
			return
		hud.inventory.visible = false
		item.used(player_node, self)
		item.remove()
		game_params.set_multistate_state(get_path(), STATE_OPENED)
		visible = false

func item_match(item):
	if not item:
		return false
	return item.nam == "barn_lock_key"

func add_highlight(player_node):
	#door_mesh.mesh.surface_set_material(surface_idx_door, null)
#	door_mesh.set_surface_material(surface_idx_door, outlined_material)
	var hud = game_params.get_hud()
	if hud and hud.get_active_item():
		var item = hud.get_active_item()
		if item_match(item):
			return "E: " + tr("ACTION_OPEN")

func remove_highlight(player_node):
	pass

func restore_state():
	var state = game_params.get_multistate_state(get_path())
	if state == STATE_OPENED:
		visible = false
