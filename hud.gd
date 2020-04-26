extends Control

const ALPHA_THRESHOLD = 0.01
const ALPHA_DECREASE_FACTOR = 0.9
const MAX_VISIBLE_ITEMS = 6
const COLOR_BLOOD = Color(1.0, 0.0, 0.0, 1.0)
const COLOR_DIMMED = Color(0.0, 0.0, 0.0, 0.5)
const COLOR_TRANSPARENT = Color(0.0, 0.0, 0.0, 0.0)

onready var main_hud = get_node("VBoxContainer/MainHUD")
onready var quick_items_dimmer = main_hud.get_node("QuickItemsDimmer")
onready var quick_items_panel = main_hud.get_node("QuickItemsDimmer/HBoxQuickItems")
onready var info_label = main_hud.get_node("HBoxInfo/InfoLabel")
onready var inventory = get_node("VBoxContainer/Inventory")
onready var inventory_panel = inventory.get_node("HBoxContainer/InventoryContainer")
onready var actions_panel = get_node("VBoxContainer/ActionsPanel")
onready var message_label = get_node("HBoxMessages/VBoxContainer/Label")
onready var conversation = get_node("VBoxContainer/Conversation")
onready var dimmer = get_node("Dimmer")
onready var tablet = get_node("tablet")

onready var indicator_crouch = get_node("Indicators/IndicatorCrouchPanel/IndicatorCrouch")
onready var tex_crouch_off = preload("res://assets/ui/tex_crouch_off.tres")
onready var tex_crouch_on = preload("res://assets/ui/tex_crouch_on.tres")

onready var health_bar = get_node("Info/MainPlayer/Stats/HealthBar")
onready var health_label = health_bar.get_node("HealthLabel")
onready var health_progress = health_bar.get_node("HealthProgress")

var active_item_idx = 0
var active_quick_item_idx = 0
var first_item_idx = 0

func _ready():
	game_params.connect("item_removed", self, "remove_ui_inventory_item")
	game_params.connect("item_removed", self, "remove_ui_quick_item")
	game_params.connect("health_changed", self, "on_health_changed")
	settings.connect("language_changed", self, "on_language_changed")
	on_health_changed(PalladiumPlayer.PLAYER_NAME_HINT, game_params.player_health_current, game_params.player_health_max)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	var dialog = $QuitDialog
	dialog.get_ok().text = "Yes"
	dialog.get_cancel().text = "No"
	get_tree().set_auto_accept_quit(false)
	synchronize_items()
	select_active_item()
	select_active_quick_item()

func set_message(text):
	message_label.text = text

func clear_message():
	set_message("")

func on_health_changed(name_hint, health_current, health_max):
	health_label.text = "%d/%d" % [health_current, health_max]
	if health_current < health_progress.value and $BloodSplatTimer.is_stopped():
		$BloodSplat.visible = true
		$BloodSplat.set_modulate(COLOR_BLOOD)
		$BloodSplatTimer.start()
	health_progress.value = health_current
	health_progress.max_value = health_max

func on_language_changed(ID):
	select_active_item()
	select_active_quick_item()

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		ask_quit()

func is_menu_hud():
	return false

func ask_quit():
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	dimmer.visible = true
	$QuitDialog.popup_centered()

func set_quick_items_dimmed(dimmed):
	var panel_style = quick_items_dimmer.get("custom_styles/panel")
	panel_style.set("bg_color", COLOR_DIMMED if dimmed else COLOR_TRANSPARENT)

func _process(delta):
	# ----------------------------------
	# Inventory on/off
	if Input.is_action_just_pressed("inventory_toggle") and not conversation_manager.conversation_active():
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

func show_tablet(is_show):
	if is_show:
		dimmer.visible = true
		tablet.visible = true
		get_tree().paused = true
		tablet._on_HomeButton_pressed()
	else:
		get_tree().paused = false
		tablet.visible = false
		dimmer.visible = false
		settings.save_settings()

func set_crouch_indicator(crouch):
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
	for pos in range(0, game_params.MAX_QUICK_ITEMS):
		insert_ui_quick_item(pos)

func insert_ui_inventory_item(pos):
	var new_item = load("res://item.tscn").instance()
	new_item.connect("used", game_params, "item_used")
	var i = first_item_idx + pos
	if i >= 0 and i < game_params.inventory.size():
		new_item.set_item_data(game_params.inventory[i].nam, game_params.inventory[i].count)
	inventory_panel.add_child(new_item)
	if pos < inventory_panel.get_child_count() - 1:
		inventory_panel.move_child(new_item, pos)
	select_active_item()

func insert_ui_quick_item(pos):
	var new_item = load("res://item.tscn").instance()
	new_item.connect("used", game_params, "item_used")
	new_item.set_appearance(true, false)
	if pos < game_params.quick_items.size():
		var quick_item = game_params.quick_items[pos]
		if quick_item.nam:
			new_item.set_item_data(quick_item.nam, quick_item.count)
	quick_items_panel.add_child(new_item)
	if pos < quick_items_panel.get_child_count() - 1:
		quick_items_panel.move_child(new_item, pos)
	select_active_quick_item()

func remove_ui_inventory_item(nam, count):
	var ui_items = inventory_panel.get_children()
	var idx = 0
	for ui_item in ui_items:
		if nam == ui_item.nam and count <= 0:
			inventory_panel.remove_child(ui_item)
			ui_item.disconnect("used", game_params, "item_used")
			ui_item.queue_free()
			insert_ui_inventory_item(MAX_VISIBLE_ITEMS - 1)
			if idx == active_item_idx and active_item_idx > 0:
				set_active_item(active_item_idx - 1)
		idx = idx + 1
	if inventory_panel.get_child(0).is_empty():
		# If very first item is empty, than all following items are empty too
		# Therefore we should try to shift visible items window to the left
		first_item_idx = int(max(game_params.inventory.size() - MAX_VISIBLE_ITEMS, 0))
		synchronize_items()
		set_active_item(0)

func remove_ui_quick_item(nam, count):
	var ui_items = quick_items_panel.get_children()
	var idx = 0
	for ui_item in ui_items:
		if nam == ui_item.nam and count <= 0:
			quick_items_panel.remove_child(ui_item)
			ui_item.disconnect("used", game_params, "item_used")
			ui_item.queue_free()
			insert_ui_quick_item(idx)
			return
		idx = idx + 1

func shift_items_left():
	if first_item_idx < game_params.inventory.size() - MAX_VISIBLE_ITEMS:
		first_item_idx = first_item_idx + 1
		var ui_item = inventory_panel.get_child(0)
		remove_ui_inventory_item(ui_item.nam, -1)

func shift_items_right():
	if first_item_idx > 0:
		first_item_idx = first_item_idx - 1
		inventory_panel.get_child(MAX_VISIBLE_ITEMS - 1).queue_free()
		insert_ui_inventory_item(0)

func is_valid_index(item_idx):
	return item_idx >= 0 and item_idx < MAX_VISIBLE_ITEMS and first_item_idx + item_idx < game_params.inventory.size()

func is_valid_quick_index(item_idx):
	return item_idx >= 0 and item_idx < game_params.MAX_QUICK_ITEMS

func select_active_item():
	var items = inventory_panel.get_children()
	if items.empty():
		return
	var idx = 0
	for item in items:
		if items[idx].nam:
			var label_key = items[idx].get_node("ItemBox/LabelKey")
			label_key.text = "F" + str(idx + 1)
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

func select_active_quick_item():
	var items = quick_items_panel.get_children()
	if items.empty():
		return
	var idx = 0
	for item in items:
		var is_active = idx == active_quick_item_idx
		items[idx].set_selected(is_active)
		if is_active and (not inventory.is_visible_in_tree() or not is_valid_index(active_item_idx)):
			info_label.text = tr(items[idx].nam) if items[idx].nam else ""
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
	if is_valid_quick_index(active_quick_item_idx) and quick_items_panel.get_child(active_quick_item_idx).nam:
		return quick_items_panel.get_child(active_quick_item_idx)
	return null

func restore_state():
	synchronize_items()

func _on_Inventory_visibility_changed():
	set_quick_items_dimmed(inventory.is_visible_in_tree())

func _on_QuitDialog_confirmed():
	get_tree().quit()

func _on_QuitDialog_popup_hide():
	if not tablet.visible:
		get_tree().paused = false
		dimmer.visible = false
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_QuitDialog_about_to_show():
	get_tree().paused = true

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
				game_params.set_quick_item(active_quick_item_idx, item.nam)
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
	elif not conversation.visible:
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
