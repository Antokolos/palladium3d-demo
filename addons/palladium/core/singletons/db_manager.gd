extends Node
class_name PLDDBManager

onready var items_db = get_items_db()

func get_items_db():
	if not items_db:
		items_db = open_json_db("items")
	return items_db

func open_json_db(db_name):
	if not db_name:
		push_error("FATAL ERROR: db_name not specified")
		get_tree().quit()
		return null
	var f = File.new()
	if f.open("res://db/%s.json" % db_name, File.READ) != OK:
		push_error("FATAL ERROR: cannot open json db file '%s.json'" % db_name)
		get_tree().quit()
		return null
	var json_result = JSON.parse(f.get_as_text())
	f.close()
	if json_result.error != OK:
		push_error("FATAL ERROR: error parsing '%s.json'" % db_name)
		push_error("Error line: %d" % json_result.error_line)
		push_error("Error string: %s" % json_result.error_string)
		get_tree().quit()
		return null
	return json_result.result