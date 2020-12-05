extends Control
class_name PLDHUD

const MESSAGE_TIMEOUT_ITEM_S = 2
const MESSAGE_TIMEOUT_MAX_S = 5
const ALPHA_THRESHOLD = 0.01
const ALPHA_DECREASE_FACTOR = 0.9
const MAX_VISIBLE_ITEMS = 6
const COLOR_WHITE = Color(1.0, 1.0, 1.0, 1.0)
const COLOR_BLOOD = Color(1.0, 0.0, 0.0, 1.0)
const COLOR_DIMMED = Color(0.0, 0.0, 0.0, 0.5)
const COLOR_TRANSPARENT = Color(0.0, 0.0, 0.0, 0.0)

export var cutscene_mode = false

onready var main_hud = get_node("VBoxContainer/MainHUD")
onready var quick_items_dimmer = main_hud.get_node("QuickItemsDimmer")
onready var quick_items_panel = main_hud.get_node("QuickItemsDimmer/HBoxQuickItems")
onready var info_label = main_hud.get_node("HBoxInfo/InfoLabel")
onready var inventory = get_node("VBoxContainer/Inventory")
onready var inventory_panel = inventory.get_node("HBoxContainer/InventoryContainer")
onready var actions_panel = get_node("VBoxContainer/ActionsPanel")
onready var message_labels = [
	get_node("HBoxMessages/VBoxContainer/Label"),
	get_node("HBoxMessages/VBoxContainer/Label2"),
	get_node("HBoxMessages/VBoxContainer/Label3")
]
onready var conversation = get_node("VBoxContainer/Conversation")
onready var dimmer = get_node("Dimmer")
onready var tablet = get_node("tablet")
onready var crosshair = get_node("Crosshair")
onready var surge_effect = get_node("SurgeEffect")
onready var underwater_effect = get_node("UnderwaterEffect")

onready var indicators_panel = get_node("Indicators")
onready var indicator_crouch = indicators_panel.get_node("IndicatorCrouchPanel/IndicatorCrouch")
onready var tex_crouch_off = preload("res://addons/palladium/assets/ui/tex_crouch_off.tres")
onready var tex_crouch_on = preload("res://addons/palladium/assets/ui/tex_crouch_on.tres")

onready var info_panel = get_node("Info")
onready var health_bar = info_panel.get_node("MainPlayer/Stats/HealthBar")
onready var health_label = health_bar.get_node("Label")
onready var health_progress = health_bar.get_node("Progress")
onready var oxygen_bar = info_panel.get_node("MainPlayer/Stats/OxygenBar")
onready var oxygen_label = oxygen_bar.get_node("Label")
onready var oxygen_progress = oxygen_bar.get_node("Progress")

var active_item_idx = 0
var active_quick_item_idx = 0
var first_item_idx = 0
var popup_message_queue = []

func _ready():
	game_state.connect("shader_cache_processed", self, "_on_shader_cache_processed")
	game_state.connect("item_taken", self, "_on_item_taken")
	game_state.connect("item_removed", self, "_on_item_removed")
	game_state.connect("health_changed", self, "on_health_changed")
	game_state.connect("oxygen_changed", self, "on_oxygen_changed")
	game_state.connect("player_surge", self, "set_surge")
	game_state.connect("player_underwater", self, "set_underwater")
	settings.connect("language_changed", self, "on_language_changed")
	on_health_changed(CHARS.PLAYER_NAME_HINT, game_state.player_health_current, game_state.player_health_max)
	on_oxygen_changed(CHARS.PLAYER_NAME_HINT, game_state.player_oxygen_current, game_state.player_oxygen_max)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	synchronize_items()
	select_active_item()
	select_active_quick_item()
	show_game_ui(not cutscene_mode)

func has_game_ui():
	return info_panel.visible and indicators_panel.visible and crosshair.visible

func show_game_ui(enable):
	var v = enable and not cutscene_mode
	info_panel.visible = v
	indicators_panel.visible = v
	quick_items_panel.visible = v
	info_label.visible = v
	crosshair.visible = v
	if not v:
		inventory.visible = false

func queue_popup_message(template, args = [], fade = false, timeout_max = MESSAGE_TIMEOUT_MAX_S):
	if game_state.get_message_state(template):
		game_state.set_message_state(template, false)
		popup_message_queue.push_back({
			"template" : template,
			"args" : args,
			"fade" : fade,
			"timeout_max" : timeout_max,
			"timeout" : timeout_max,
			"label_idx" : -1
		})

func process_popup_messages(delta):
	if popup_message_queue.empty():
		return
	for i in range(0, popup_message_queue.size()):
		var message = popup_message_queue[i]
		if message.label_idx < 0:
			var idx = set_popup_message(message.template, message.args)
			if idx >= 0:
				message.label_idx = idx
	var message = popup_message_queue.front()
	if message.timeout > 0:
		if message.fade:
			var m = message_labels[0].get_modulate()
			m.a = message.timeout / message.timeout_max
			message_labels[0].set_modulate(m)
		message.timeout = message.timeout - delta
	else:
		clear_popup_message()
		message_labels[0].set_modulate(COLOR_WHITE)

func set_popup_message(template, args = []):
	var i = 0
	for label in message_labels:
		if not label.visible:
			label.visible = true
			label.set_modulate(COLOR_WHITE)
			label.text = tr(template) % args
			return i
		i = i + 1
	return -1

func clear_popup_message():
	message_labels[0].set_modulate(COLOR_WHITE)
	message_labels[0].text = message_labels[1].text if message_labels[1].visible else ""
	message_labels[0].visible = message_labels[1].visible
	message_labels[1].text = message_labels[2].text if message_labels[2].visible else ""
	message_labels[1].visible = message_labels[2].visible
	message_labels[2].text = ""
	message_labels[2].visible = false
	if not popup_message_queue.empty():
		popup_message_queue.pop_front()
	return not message_labels[0].visible

func on_health_changed(name_hint, health_current, health_max):
	health_label.text = "%d/%d" % [health_current, health_max]
	if health_current < health_progress.value and $BloodSplatTimer.is_stopped():
		$BloodSplat.visible = true
		$BloodSplat.set_modulate(COLOR_BLOOD)
		$BloodSplatTimer.start()
	health_progress.value = health_current
	health_progress.max_value = health_max

func on_oxygen_changed(name_hint, oxygen_current, oxygen_max):
	oxygen_bar.visible = oxygen_current < oxygen_max
	oxygen_label.text = "%d/%d" % [oxygen_current, oxygen_max]
	oxygen_progress.value = oxygen_current
	oxygen_progress.max_value = oxygen_max

func on_crouching_changed(player_node, previous_state, new_state):
	if player_node and player_node.is_player():
		set_crouch_indicator(new_state)

func on_language_changed(ID):
	select_active_item()
	select_active_quick_item()

func is_menu_hud():
	return false

func is_tablet_visible():
	return tablet.visible

func is_in_conversation():
	return conversation.visible or conversation_manager.conversation_is_in_progress()

func is_quit_dialog_visible():
	return get_node("quit_dialog").visible

func pause_game(enable, with_dimmer = true):
	dimmer.visible = with_dimmer and enable
	get_tree().paused = enable
	var player = game_state.get_player()
	if player:
		player.reset_movement()

func set_surge(player, enable):
	if player and not player.equals(game_state.get_player()):
		return
	surge_effect.visible = enable

func set_underwater(player, enable):
	if player and not player.equals(game_state.get_player()):
		return
	underwater_effect.visible = enable

func set_quick_items_dimmed(dimmed):
	var panel_style = quick_items_dimmer.get("custom_styles/panel")
	panel_style.set("bg_color", COLOR_DIMMED if dimmed else COLOR_TRANSPARENT)

func _process(delta):
	# ----------------------------------
	# Inventory on/off
	if Input.is_action_just_pressed("inventory_toggle") and not conversation_manager.conversation_is_in_progress():
		if inventory.visible:
			inventory.visible = false
			select_active_quick_item()
		else:
			inventory.visible = true
			select_active_item()
	# ----------------------------------
	
	# ----------------------------------
	# Capturing/Freeing the cursor
	if Input.is_action_just_pressed("ui_tablet_toggle"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			show_tablet(false)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			show_tablet(true)
	# ----------------------------------
	
	process_popup_messages(delta)

func show_tablet(is_show):
	if is_show:
		pause_game(true)
		tablet.activate(PLDTablet.ActivationMode.DESKTOP)
	else:
		tablet.visible = false
		pause_game(false)
		settings.save_settings()
		settings.save_input()

func set_crouch_indicator(crouch):
	# TODO: indicator_crouch can be null when loading the game from save, because hud is not initialized yet, maybe this code should be refactored
	if indicator_crouch:
		indicator_crouch.set("texture", tex_crouch_on if crouch else tex_crouch_off)

func cleanup_panel(panel):
	var ui_items = panel.get_children()
	for ui_item in ui_items:
		panel.remove_child(ui_item)
		ui_item.queue_free()

func synchronize_items():
	cleanup_panel(inventory_panel)
	for pos in range(0, MAX_VISIBLE_ITEMS):
		insert_ui_inventory_item(pos)
	cleanup_panel(quick_items_panel)
	for pos in range(0, DB.MAX_QUICK_ITEMS):
		insert_ui_quick_item(pos)

func insert_ui_inventory_item(pos):
	var new_item = load("res://addons/palladium/ui/item.tscn").instance()
	new_item.connect("used", game_state, "item_used")
	var i = first_item_idx + pos
	if i >= 0 and i < game_state.inventory.size():
		new_item.set_item_data(game_state.inventory[i].item_id, game_state.inventory[i].count)
	inventory_panel.add_child(new_item)
	if pos < inventory_panel.get_child_count() - 1:
		inventory_panel.move_child(new_item, pos)
	select_active_item()

func insert_ui_quick_item(pos):
	var new_item = load("res://addons/palladium/ui/item.tscn").instance()
	new_item.connect("used", game_state, "item_used")
	new_item.set_appearance(true, false)
	if pos < game_state.quick_items.size():
		var quick_item = game_state.quick_items[pos]
		if quick_item.item_id:
			new_item.set_item_data(quick_item.item_id, quick_item.count)
	quick_items_panel.add_child(new_item)
	if pos < quick_items_panel.get_child_count() - 1:
		quick_items_panel.move_child(new_item, pos)
	select_active_quick_item()

func _on_shader_cache_processed():
	if cutscene_mode:
		return
	queue_popup_message("MESSAGE_CONTROLS_MOVE", ["WASD", "Shift"])
	if game_state.get_quick_items_count() > 0:
		queue_popup_message("MESSAGE_CONTROLS_EXAMINE", ["Q"])

func _on_item_taken(item_id, cnt, item_path):
	queue_popup_message("MESSAGE_ITEM_TAKEN", [tr(DB.get_item_name(item_id))], true, MESSAGE_TIMEOUT_ITEM_S)
	synchronize_items()

func _on_item_removed(item_id, cnt):
	remove_ui_inventory_item(item_id, cnt)
	remove_ui_quick_item(item_id, cnt)
	synchronize_items()

func remove_ui_inventory_item(item_id, count):
	var ui_items = inventory_panel.get_children()
	var idx = 0
	for ui_item in ui_items:
		if item_id == ui_item.item_id and count <= 0:
			inventory_panel.remove_child(ui_item)
			ui_item.disconnect("used", game_state, "item_used")
			ui_item.queue_free()
			insert_ui_inventory_item(MAX_VISIBLE_ITEMS - 1)
			if idx == active_item_idx and active_item_idx > 0:
				set_active_item(active_item_idx - 1)
		idx = idx + 1
	if inventory_panel.get_child(0).is_empty():
		# If very first item is empty, than all following items are empty too
		# Therefore we should try to shift visible items window to the left
		first_item_idx = int(max(game_state.inventory.size() - MAX_VISIBLE_ITEMS, 0))
		synchronize_items()
		set_active_item(0)

func remove_ui_quick_item(item_id, count):
	var ui_items = quick_items_panel.get_children()
	var idx = 0
	for ui_item in ui_items:
		if item_id == ui_item.item_id and count <= 0:
			quick_items_panel.remove_child(ui_item)
			ui_item.disconnect("used", game_state, "item_used")
			ui_item.queue_free()
			insert_ui_quick_item(idx)
			return
		idx = idx + 1

func shift_items_left():
	if first_item_idx < game_state.inventory.size() - MAX_VISIBLE_ITEMS:
		first_item_idx = first_item_idx + 1
		var ui_item = inventory_panel.get_child(0)
		remove_ui_inventory_item(ui_item.item_id, -1)

func shift_items_right():
	if first_item_idx > 0:
		first_item_idx = first_item_idx - 1
		inventory_panel.get_child(MAX_VISIBLE_ITEMS - 1).queue_free()
		insert_ui_inventory_item(0)

func is_valid_index(item_idx):
	return item_idx >= 0 and item_idx < MAX_VISIBLE_ITEMS and first_item_idx + item_idx < game_state.inventory.size()

func is_valid_quick_index(item_idx):
	return item_idx >= 0 and item_idx < DB.MAX_QUICK_ITEMS

func select_active_item():
	var items = inventory_panel.get_children()
	if items.empty():
		return
	var idx = 0
	for item in items:
		if items[idx].item_id and items[idx].item_id != DB.TakableIds.NONE:
			var label_key = items[idx].get_node("ItemBox/LabelKey")
			label_key.text = str(idx + 1)
			if idx == active_item_idx:
				items[idx].set_selected(true)
				label_key.set("custom_colors/font_color", Color(1, 0, 0))
				if inventory.is_visible_in_tree():
					info_label.text = common_utils.get_action_key("active_item_toggle") + tr("ACTION_TOGGLE_QUICK_ITEM")
			else:
				items[idx].set_selected(false)
				label_key.set("custom_colors/font_color", Color(1, 1, 1))
		idx = idx + 1

func set_active_item(item_idx):
	var valid = is_valid_index(item_idx)
	if valid:
		active_item_idx = item_idx
		select_active_item()
	return valid

func activate_item_use(item):
	var player = game_state.get_player()
	if not player:
		return
	var cam = player.get_cam()
	if not cam:
		return
	cam.activate_item_use(item)

func select_active_quick_item():
	var items = quick_items_panel.get_children()
	if items.empty():
		return
	var idx = 0
	if active_quick_item_idx < items.size():
		activate_item_use(items[active_quick_item_idx])
	for item in items:
		var is_active = idx == active_quick_item_idx
		items[idx].set_selected(is_active)
		if is_active and (not inventory.is_visible_in_tree() or not is_valid_index(active_item_idx)):
			info_label.text = tr(DB.get_item_name(items[idx].item_id)) if items[idx].item_id and items[idx].item_id != DB.TakableIds.NONE else ""
		idx = idx + 1

func set_active_quick_item(item_idx):
	var valid = is_valid_quick_index(item_idx)
	if valid:
		quick_items_panel.get_child(active_quick_item_idx).set_selected(false)
		quick_items_panel.get_child(item_idx).set_selected(true)
		active_quick_item_idx = item_idx
		select_active_quick_item()
	return valid

func get_active_item():
	if inventory_panel.is_visible_in_tree() and is_valid_index(active_item_idx):
		return inventory_panel.get_child(active_item_idx)
	if is_valid_quick_index(active_quick_item_idx) and quick_items_panel.get_child(active_quick_item_idx).item_id:
		return quick_items_panel.get_child(active_quick_item_idx)
	return null

func restore_state():
	synchronize_items()
	set_crouch_indicator(game_state.get_player().is_crouching())

func _on_Inventory_visibility_changed():
	set_quick_items_dimmed(inventory.is_visible_in_tree())

func _input(event):
	if inventory.is_visible_in_tree():
		if event.is_action_pressed("active_item_back"):
			if not set_active_item(active_item_idx - 1):
				shift_items_right()
		elif event.is_action_pressed("active_item_next"):
			if not set_active_item(active_item_idx + 1):
				shift_items_left()
		elif event.is_action_pressed("active_item_toggle"):
			var item = get_active_item()
			if item:
				game_state.set_quick_item(active_quick_item_idx, item.item_id)
				synchronize_items()
		elif event.is_action_pressed("active_item_1"):
			set_active_item(0)
		elif event.is_action_pressed("active_item_2"):
			set_active_item(1)
		elif event.is_action_pressed("active_item_3"):
			set_active_item(2)
		elif event.is_action_pressed("active_item_4"):
			set_active_item(3)
		elif event.is_action_pressed("active_item_5"):
			set_active_item(4)
		elif event.is_action_pressed("active_item_6"):
			set_active_item(5)
	elif not is_in_conversation():
		if event.is_action_pressed("active_item_back"):
			set_active_quick_item(active_quick_item_idx - 1)
		elif event.is_action_pressed("active_item_next"):
			set_active_quick_item(active_quick_item_idx + 1)
		if event.is_action_pressed("active_item_1"):
			set_active_quick_item(0)
		elif event.is_action_pressed("active_item_2"):
			set_active_quick_item(1)
		elif event.is_action_pressed("active_item_3"):
			set_active_quick_item(2)
		elif event.is_action_pressed("active_item_4"):
			set_active_quick_item(3)
		elif event.is_action_pressed("active_item_5"):
			set_active_quick_item(4)
		elif event.is_action_pressed("active_item_6"):
			set_active_quick_item(5)

func _on_BloodSplatTimer_timeout():
	var m = $BloodSplat.get_modulate()
	if m.a > ALPHA_THRESHOLD:
		m.a = m.a * ALPHA_DECREASE_FACTOR
	else:
		$BloodSplat.visible = false
		$BloodSplatTimer.stop()
	$BloodSplat.set_modulate(m)
