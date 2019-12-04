extends Control

onready var main_hud = get_node("VBoxContainer/MainHUD")
onready var quick_items_panel = main_hud.get_node("HBoxQuickItems")
onready var inventory = get_node("VBoxContainer/Inventory")
onready var inventory_panel = inventory.get_node("HBoxContainer/InventoryContainer")
onready var conversation = get_node("VBoxContainer/Conversation")
onready var dimmer = get_node("Dimmer")
onready var tablet = get_node("tablet")

onready var indicator_crouch = get_node("Indicators/Indicators_border/IndicatorCrouch")
onready var tex_crouch_off = preload("res://assets/ui/tex_crouch_off.tres")
onready var tex_crouch_on = preload("res://assets/ui/tex_crouch_on.tres")

const MAX_VISIBLE_ITEMS = 3

var active_item_idx = 0
var active_quick_item_idx = 0
var first_item_idx = 0

func _ready():
	settings.connect("resolution_changed", self, "on_resolution_changed")
	game_params.connect("item_removed", self, "remove_ui_inventory_item")
	game_params.connect("item_removed", self, "remove_ui_quick_item")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	var dialog = $QuitDialog
	dialog.get_ok().text = "Yes"
	dialog.get_cancel().text = "No"
	get_tree().set_auto_accept_quit(false)
	synchronize_items()
	select_active_item()
	select_active_quick_item()

func on_resolution_changed(ID):
	var hud = self
	var default_font = hud.get_theme().get_default_font()
	var conversation_root = hud.get_conversation_root()
	var actorname_prev_font = hud.get_actorname_prev().get("custom_fonts/font")
	var conversation_prev_font = hud.get_conversation_text_prev().get("custom_fonts/font")
	var actorname_font = hud.get_actorname().get("custom_fonts/font")
	var conversation_font = hud.get_conversation_text().get("custom_fonts/font")
	var maxid = settings.available_resolutions.size() - 1
	if ID > maxid:
		# TODO: maybe upscale font size for native resolution?
		default_font.set_size(settings.available_resolutions[maxid].default_font)
		actorname_prev_font.set_size(settings.available_resolutions[maxid].actorname_prev_font)
		conversation_prev_font.set_size(settings.available_resolutions[maxid].conversation_prev_font)
		actorname_font.set_size(settings.available_resolutions[maxid].actorname_font)
		conversation_font.set_size(settings.available_resolutions[maxid].conversation_font)
		conversation_root.set("custom_constants/separation", settings.available_resolutions[maxid].text_separation)
	else:
		default_font.set_size(settings.available_resolutions[ID].default_font)
		actorname_prev_font.set_size(settings.available_resolutions[ID].actorname_prev_font)
		conversation_prev_font.set_size(settings.available_resolutions[ID].conversation_prev_font)
		actorname_font.set_size(settings.available_resolutions[ID].actorname_font)
		conversation_font.set_size(settings.available_resolutions[ID].conversation_font)
		conversation_root.set("custom_constants/separation", settings.available_resolutions[ID].text_separation)

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		ask_quit()

func is_menu_hud():
	return false

func get_conversation_root():
	return get_node("VBoxContainer/Conversation/VBox")

func get_actorname_prev():
	return get_conversation_root().get_node("VBoxText/HBoxTextPrev/ActorName")

func get_conversation_text_prev():
	return get_conversation_root().get_node("VBoxText/HBoxTextPrev/ConversationText")

func get_actorname():
	return get_conversation_root().get_node("VBoxText/HBoxText/ActorName")

func get_conversation_text():
	return get_conversation_root().get_node("VBoxText/HBoxText/ConversationText")

func ask_quit():
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		dimmer.visible = true
	get_tree().paused = true
	$QuitDialog.popup_centered()

func _process(delta):
	# ----------------------------------
	# Inventory on/off
	if Input.is_action_just_pressed("ui_focus_next") and not conversation_manager.conversation_active():
		if inventory.visible:
			inventory.visible = false
		else:
			inventory.visible = true
	# ----------------------------------
	
	# ----------------------------------
	# Capturing/Freeing the cursor
	if Input.is_action_just_pressed("ui_cancel"):
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
	indicator_crouch.set("custom_styles/panel", tex_crouch_on if crouch else tex_crouch_off)

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
	var i = first_item_idx + pos
	if i >= 0 and i < game_params.inventory.size():
		new_item.set_item_data(game_params.inventory[i])
	inventory_panel.add_child(new_item)
	if pos < inventory_panel.get_child_count() - 1:
		inventory_panel.move_child(new_item, pos)
	select_active_item()

func insert_ui_quick_item(pos):
	var new_item = load("res://item.tscn").instance()
	new_item.set_appearance(true, false)
	for quick_item in game_params.quick_items:
		if pos == quick_item.pos:
			for item in game_params.inventory:
				if quick_item.nam == item.nam:
					new_item.set_item_data(item)
					break
			break
	quick_items_panel.add_child(new_item)
	if pos < quick_items_panel.get_child_count() - 1:
		quick_items_panel.move_child(new_item, pos)
	select_active_quick_item()

func refresh_ui_quick_item(pos):
	for quick_item in game_params.quick_items:
		if pos == quick_item.pos:
			for item in game_params.inventory:
				if quick_item.nam == item.nam:
					quick_items_panel.get_child(pos).set_item_data(item)
					break
			break
	select_active_quick_item()

func remove_ui_inventory_item(nam, count):
	var ui_items = inventory_panel.get_children()
	var idx = 0
	for ui_item in ui_items:
		if nam == ui_item.nam and count <= 0:
			inventory_panel.remove_child(ui_item)
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
		items[idx].set_selected(idx == active_quick_item_idx)
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

func _on_QuitDialog_confirmed():
	get_tree().quit()

func _on_QuitDialog_popup_hide():
	if not tablet.visible:
		get_tree().paused = false
		dimmer.visible = false
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if event is InputEventKey and event.is_pressed():
		if inventory.is_visible_in_tree():
			if event.scancode == KEY_B:
				if not set_active_item(active_item_idx - 1):
					shift_items_right()
				return
			if event.scancode == KEY_N:
				if not set_active_item(active_item_idx + 1):
					shift_items_left()
				return
			if event.scancode == KEY_T:
				var item = get_active_item()
				if item:
					game_params.set_quick_item(active_quick_item_idx, item.nam)
					refresh_ui_quick_item(active_quick_item_idx)
				return
			if event.scancode >= KEY_F1 and event.scancode <= KEY_F6:
				set_active_item(event.scancode - KEY_F1)
				return
		elif not conversation.visible:
			if event.scancode >= KEY_1 and event.scancode <= KEY_6:
				set_active_quick_item(event.scancode - KEY_1)
				return
