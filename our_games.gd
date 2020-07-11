extends TextureRect

const APPIDS = [ 1040310, 531630, 815070, 594320, 490690, 392820 ]

onready var main_panel = get_node("VBoxContainer/HBoxContainer/PanelContainer")
onready var site_url_node = main_panel.get_node("VBoxContainer/HBoxAuthor/SiteUrl")
onready var tab_node = main_panel.get_node("VBoxContainer/GamesContent/HBoxContainerInfo/TabContainer")
onready var back_node = main_panel.get_node("VBoxContainer/HBoxControls/Back")
onready var button_open_node = main_panel.get_node("VBoxContainer/GameActions/ButtonOpen")

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
	game_params.change_scene("res://main_menu.tscn")

func _on_SiteUrl_meta_clicked(meta):
	common_utils.open_url("https://nlbproject.com")

func select_tab(tab_index):
	tab_node.set("current_tab", tab_index)
	button_open_node.visible = common_utils.is_steam_running()

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

func _on_ButtonOpen_pressed():
	common_utils.open_store_page(APPIDS[tab_node.get("current_tab")])

func _input(event):
	if common_utils.is_event_cancel_action(event):
		_on_Back_pressed()
