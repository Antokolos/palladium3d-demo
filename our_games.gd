extends TextureRect

onready var site_url_node = get_node("VBoxContainer/HBoxAuthor/SiteUrl")
onready var tab_node = get_node("VBoxContainer/GamesContent/HBoxContainerInfo/TabContainer")
onready var back_node = get_node("VBoxContainer/HBoxControls/Back")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	site_url_node.push_meta(0)
	site_url_node.append_bbcode("https://nlbproject.com")
	site_url_node.pop()
	for i in range(tab_node.get_tab_count()):
		tab_node.set_tab_title(i, tr(tab_node.get_tab_title(i)))
	select_tab(0)
	back_node.grab_focus()

func _on_Back_pressed():
	game_params.scene_path = "res://main_menu.tscn"
	get_tree().change_scene("res://scene_loader.tscn")

func _on_SiteUrl_meta_clicked(meta):
	common_utils.open_url("https://nlbproject.com")

func _on_ButtonIKE_pressed():
	common_utils.open_store_page(1040310)

func _on_ButtonNonlinearTQ_pressed():
	common_utils.open_store_page(531630)

func _on_ButtonAdvFour_pressed():
	common_utils.open_store_page(815070)

func _on_ButtonRedHood_pressed():
	common_utils.open_store_page(594320)

func _on_ButtonBarbarian_pressed():
	common_utils.open_store_page(490690)

func _on_ButtonWIQ_pressed():
	common_utils.open_store_page(392820)

func select_tab(tab_index):
	tab_node.set("current_tab", tab_index)
	tab_node.get_current_tab_control().get_node("ButtonOpen").visible = common_utils.is_steam_running()

func _on_ABOUT_CAPTION_IKE_pressed():
	select_tab(0)

func _on_ABOUT_CAPTION_NONLINEAR_TQ_pressed():
	select_tab(1)

func _on_ABOUT_CAPTION_ADVFOUR_pressed():
	select_tab(2)

func _on_ABOUT_CAPTION_REDHOOD_pressed():
	select_tab(3)

func _on_ABOUT_CAPTION_BARBARIAN_pressed():
	select_tab(4)

func _on_ABOUT_CAPTION_WIQ_pressed():
	select_tab(5)

func _input(event):
	if common_utils.is_event_cancel_action(event):
		_on_Back_pressed()
