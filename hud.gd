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

const MAX_VISIBLE_ITEMS = 3

var active_item_idx = -1
var first_item_idx = 0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	var dialog = $QuitDialog
	dialog.get_ok().text = "Yes"
	dialog.get_cancel().text = "No"
	get_tree().set_auto_accept_quit(false)
	synchronize_items()

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
		active_item_idx = -1
		if inventory.visible:
			inventory.visible = false
			hints.visible = true
		else:
			inventory.visible = true
			hints.visible = false
			var items = inventory_panel.get_children()
			var idx = 0
			for item in items:
				if items[idx].nam:
					items[idx].get_node("ItemBox/LabelKey").text = "F" + str(idx + 1)
				idx = idx + 1
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

func synchronize_items():
	var idx = 0
	var ui_items = inventory_panel.get_children()
	for ui_item in ui_items:
		var i = first_item_idx + idx
		if i >= 0 and i < game_params.inventory.size():
			var item = game_params.inventory[i]
			set_item_data(ui_item, item.nam, item.item_image, item.model_path)
		idx = idx + 1

func set_item_data(ui_item, nam, item_image, model_path):
	ui_item.nam = nam
	ui_item.item_image = item_image
	ui_item.model_path = model_path
	var image_file = "res://assets/items/%s" % ui_item.item_image
	var image = load(image_file)
	var texture = ImageTexture.new()
	texture.create_from_image(image)
	ui_item.get_node("ItemBox/TextureRect").texture = texture
	ui_item.get_node("ItemBox/LabelDesc").text = tr(nam)

func shift_items_left():
	if first_item_idx < game_params.inventory.size() - MAX_VISIBLE_ITEMS:
		first_item_idx = first_item_idx + 1
		synchronize_items()

func shift_items_right():
	if first_item_idx > 0:
		first_item_idx = first_item_idx - 1
		synchronize_items()

func select_item(target_idx):
	active_item_idx = -1
	var items = inventory_panel.get_children()
	if items.empty():
		return
	var idx = 0
	for item in items:
		if items[idx].nam:
			var label_key = items[idx].get_node("ItemBox/LabelKey")
			if idx == target_idx:
				items[idx].set_selected(true)
				label_key.set("custom_colors/font_color", Color(1, 0, 0))
				active_item_idx = idx
			else:
				items[idx].set_selected(false)
				label_key.set("custom_colors/font_color", Color(1, 1, 1))
		idx = idx + 1

func get_active_item():
	return inventory_panel.get_child(active_item_idx) if active_item_idx >= 0 and active_item_idx < MAX_VISIBLE_ITEMS else null

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
			if active_item_idx > 0:
				select_item(active_item_idx - 1)
			else:
				shift_items_right()
			return
		if event.scancode == KEY_X:
			if active_item_idx < MAX_VISIBLE_ITEMS - 1:
				select_item(active_item_idx + 1)
			else:
				shift_items_left()
			return
		if event.scancode < KEY_F1 or event.scancode > KEY_F6:
			return
		select_item(event.scancode - KEY_F1)
