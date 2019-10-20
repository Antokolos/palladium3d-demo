extends Control

onready var hints = get_node("VBoxContainer/Hints")
onready var alt_hint = get_node("ActionHintLabelAlt")
onready var inventory = get_node("VBoxContainer/Inventory")
onready var inventory_panel = inventory.get_node("HBoxContainer")
onready var conversation = get_node("VBoxContainer/Conversation")
onready var dimmer = get_node("Dimmer")
onready var tablet = get_node("tablet")

onready var indicator_crouch = get_node("Indicators/Indicators_border/IndicatorCrouch")
onready var tex_crouch_off = preload("res://assets/ui/tex_crouch_off.tres")
onready var tex_crouch_on = preload("res://assets/ui/tex_crouch_on.tres")

var active_item_idx = -1

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	var dialog = $QuitDialog
	dialog.get_ok().text = "Yes"
	dialog.get_cancel().text = "No"
	get_tree().set_auto_accept_quit(false)

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		ask_quit()

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
				items[idx].get_node("LabelKey").text = "F" + str(idx + 1)
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

func take(nam, model_path):
	var item = load("res://item.tscn").instance()
	item.nam = nam
	item.model_path = model_path
	var image_file = "res://assets/items/%s.png" % nam
	var image = load(image_file)
	var texture = ImageTexture.new()
	texture.create_from_image(image)
	item.get_node("TextureRect").texture = texture
	item.get_node("LabelDesc").text = tr(nam)
	inventory_panel.add_child(item)

func get_active_item():
	return inventory_panel.get_child(active_item_idx) if active_item_idx >= 0 else null

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
		if event.scancode < KEY_F1 or event.scancode > KEY_F9:
			return
		active_item_idx = -1
		var items = inventory_panel.get_children()
		if items.empty():
			return
		var idx = 0
		var target_idx = event.scancode - KEY_F1
		for item in items:
			var label_key = items[idx].get_node("LabelKey")
			if idx == target_idx:
				label_key.set("custom_colors/font_color", Color(1, 0, 0))
				active_item_idx = idx
			else:
				label_key.set("custom_colors/font_color", Color(1, 1, 1))
			idx = idx + 1
