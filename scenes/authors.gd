extends TextureRect

onready var authors_text_label_node = get_node("VBoxContainer/HBoxAuthors/ScrollContainer/AuthorsTextLabel")

func activate():
	show()
	var lang = TranslationServer.get_locale()
	var fallback_filename = game_params.abspath("authors_en.txt")
	var filename = game_params.abspath("authors_%s.txt" % lang) if lang else fallback_filename
	authors_text_label_node.bbcode_enabled = true
	authors_text_label_node.parse_bbcode(load_file(filename, fallback_filename))

func load_file(filename, fallback_filename):
	var file = File.new()
	if file.file_exists(filename):
		file.open(filename, File.READ)
	else:
		file.open(fallback_filename, File.READ)
	var content = file.get_as_text()
	file.close()
	return content
