extends Control

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	refresh_slot_captions(get_node("ColorRect/HBoxContainer/VBoxContainer"))

func refresh_slot_captions(base_node):
	for i in range(0, 6):
		var node = base_node.get_node("VBoxContainer/Slot%d/ButtonSlot%d" % [i, i])
		var caption = story_node.get_slot_caption(i)
		var exists = game_state.save_slot_exists(i)
		node.set_disabled(not exists)
		if i > 0:
			node.text = caption if exists else tr("TABLET_EMPTY_SLOT")
		else: # i == 0
			node.text = tr("TABLET_AUTOSAVE_SLOT") + (": " + caption if exists else "")

func _on_ButtonSlot0_pressed():
	game_state.autosave_restore()

func _on_ButtonSlot1_pressed():
	game_state.initiate_load(1)

func _on_ButtonSlot2_pressed():
	game_state.initiate_load(2)

func _on_ButtonSlot3_pressed():
	game_state.initiate_load(3)

func _on_ButtonSlot4_pressed():
	game_state.initiate_load(4)

func _on_ButtonSlot5_pressed():
	game_state.initiate_load(5)

func _on_ButtonMainMenu_pressed():
	cutscene_manager.clear_cutscene_node()
	game_state.change_scene("res://main_menu.tscn")

func _on_ButtonQuit_pressed():
	get_tree().quit()
