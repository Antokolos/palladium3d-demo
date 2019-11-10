extends Control

onready var hints = get_node("VBoxContainer/Hints")
onready var alt_hint = get_node("ActionHintLabelAlt")
onready var inventory = get_node("VBoxContainer/Inventory")
onready var inventory_panel = inventory.get_node("HBoxContainer/InventoryContainer")
onready var conversation = get_node("VBoxContainer/Conversation")
onready var dimmer = get_node("Dimmer")
onready var tablet = get_node("tablet")

onready var indicator_crouch = get_node("Indicators/Indicators_border/IndicatorCrouch")
onready var tex_crouch_off = preload("res://assets/ui/tex_crouch_off.tres")
onready var tex_crouch_on = preload("res://assets/ui/tex_crouch_on.tres")

const MAX_VISIBLE_ITEMS = 6

var active_item_idx = 0
var first_item_idx = 0

func _ready():
	settings.connect("resolution_changed", self, "on_resolution_changed")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	var dialog = $QuitDialog
	dialog.get_ok().text = "Yes"
	dialog.get_cancel().text = "No"
	get_tree().set_auto_accept_quit(false)
	synchronize_items()

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
			hints.visible = true
		else:
			inventory.visible = true
			hints.visible = false
	# ----------------------------------
	
	select_active_item()
	
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

func synchronize_items():
	var ui_items = inventory_panel.get_children()
	for ui_item in ui_items:
		ui_item.queue_free()
	for pos in range(0, MAX_VISIBLE_ITEMS):
		insert_ui_item(pos, false)
	inventory.mark_restore()

func insert_ui_item(pos, add_as_first):
	var new_item = load("res://item.tscn").instance()
	new_item.connect("item_removed", self, "remove_ui_item", [true])
	var i = first_item_idx + pos
	if i >= 0 and i < game_params.inventory.size():
		new_item.set_item_data(game_params.inventory[i])
	inventory_panel.add_child(new_item)
	if add_as_first:
		inventory_panel.move_child(new_item, 0)

func remove_ui_item(ui_item, reset_idx):
	ui_item.queue_free()
	insert_ui_item(MAX_VISIBLE_ITEMS - 1, false)
	if reset_idx:
		active_item_idx = 0

func shift_items_left():
	if first_item_idx < game_params.inventory.size() - MAX_VISIBLE_ITEMS:
		first_item_idx = first_item_idx + 1
		remove_ui_item(inventory_panel.get_child(0), false)

func shift_items_right():
	if first_item_idx > 0:
		first_item_idx = first_item_idx - 1
		inventory_panel.get_child(MAX_VISIBLE_ITEMS - 1).queue_free()
		insert_ui_item(0, true)

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

func is_valid_index(item_idx):
	return item_idx >= 0 and item_idx < MAX_VISIBLE_ITEMS and first_item_idx + item_idx < game_params.inventory.size()

func set_active_item(item_idx):
	var valid = is_valid_index(item_idx)
	if valid:
		active_item_idx = item_idx
	return valid

func get_active_item():
	return inventory_panel.get_child(active_item_idx) if is_valid_index(active_item_idx) else null

func _on_QuitDialog_confirmed():
	get_tree().quit()

func _on_QuitDialog_popup_hide():
	if not tablet.visible:
		get_tree().paused = false
		dimmer.visible = false
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if inventory.is_visible_in_tree() and event is InputEventKey and event.is_pressed():
		if event.scancode == KEY_Z:
			if not set_active_item(active_item_idx - 1):
				shift_items_right()
			return
		if event.scancode == KEY_X:
			if not set_active_item(active_item_idx + 1):
				shift_items_left()
			return
		if event.scancode < KEY_F1 or event.scancode > KEY_F6:
			return
		set_active_item(event.scancode - KEY_F1)
