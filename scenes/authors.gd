extends TextureRect

const SCROLL_STEP = 40

onready var authors_label = get_node("VBoxContainer/HBoxAuthors/AuthorsTextLabel")
onready var scrollbar = authors_label.get_v_scroll()

func activate():
	show()
	var lang = TranslationServer.get_locale()
	var fallback_filename = "res://authors_en.txt"
	var filename = "res://authors_%s.txt" % lang if lang else fallback_filename
	authors_label.bbcode_enabled = true
	authors_label.parse_bbcode(load_file(filename, fallback_filename))

func _input(event):
	if not authors_label.is_visible_in_tree():
		return
	if event.is_action_pressed("ui_down") or event.is_action_pressed("ui_page_down"):
		var smax = scrollbar.get_max()
		scrollbar.value = scrollbar.value + SCROLL_STEP
		if scrollbar.value > smax:
			scrollbar.value = smax
	elif event.is_action_pressed("ui_up") or event.is_action_pressed("ui_page_up"):
		scrollbar.value = scrollbar.value - SCROLL_STEP
		if scrollbar.value < 0:
			scrollbar.value = 0

func load_file(filename, fallback_filename):
	var file = File.new()
	if file.file_exists(filename):
		file.open(filename, File.READ)
	else:
		file.open(fallback_filename, File.READ)
	var content = file.get_as_text()
	file.close()
	return content

func _on_AuthorsTextLabel_meta_clicked(meta):
	common_utils.open_url(meta)