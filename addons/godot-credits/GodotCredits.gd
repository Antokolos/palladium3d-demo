extends ColorRect
class_name GodotCredits

const section_time := 2.0
const line_time := 0.45
const base_speed := 100
const speed_up_multiplier := 10.0
const title_color := Color.yellowgreen

export(Font) var font_text
export(Font) var font_caption
export(NodePath) var credits_container_path
var scroll_speed := base_speed
var speed_up := false

onready var credits_container := get_node(credits_container_path) if has_node(credits_container_path) else null
onready var line := credits_container.get_node("Line") if credits_container else null
var started := false
var finished := false

var section
var section_next := true
var section_timer := 0.0
var line_timer := 0.0
var curr_line := 0
var lines := []

var credits = [
	[
		"A game by Awesome Game Company"
	],[
		"Programming",
		"Programmer Name",
		"Programmer Name 2"
	],[
		"Art",
		"Artist Name"
	],[
		"Music",
		"Musician Name"
	],[
		"Sound Effects",
		"SFX Name"
	],[
		"Testers",
		"Name 1",
		"Name 2",
		"Name 3"
	],[
		"Tools used",
		"Developed with Godot Engine",
		"https://godotengine.org/license",
		"",
		"Art created with My Favourite Art Program",
		"https://myfavouriteartprogram.com"
	],[
		"Special thanks",
		"My parents",
		"My friends",
		"My pet rabbit"
	]
]

func _ready():
	var fname = "res://credits_%s.txt" % TranslationServer.get_locale()
	var c = load_file(fname, "res://credits_en.txt")
	if c:
		credits = c

func load_file(filename, fallback_filename):
	var result = []
	var cur_section = []
	var file = File.new()
	if file.file_exists(filename):
		if file.open(filename, File.READ) != OK:
			return null
	else:
		if file.open(fallback_filename, File.READ) != OK:
			return null
	var t = false
	while not file.eof_reached():
		var l = file.get_line()
		if t and l.empty():
			result.append(cur_section)
			cur_section = []
			continue
		t = l.empty()
		cur_section.append(l)
	file.close()
	return result


func _process(delta):
	var scroll_speed = base_speed * delta
	
	if section_next:
		section_timer += delta * speed_up_multiplier if speed_up else delta
		if section_timer >= section_time:
			section_timer -= section_time
			
			if credits.size() > 0:
				started = true
				section = credits.pop_front()
				curr_line = 0
				add_line()
	
	else:
		line_timer += delta * speed_up_multiplier if speed_up else delta
		if line_timer >= line_time:
			line_timer -= line_time
			add_line()
	
	if speed_up:
		scroll_speed *= speed_up_multiplier
	
	if lines.size() > 0:
		for l in lines:
			l.rect_position.y -= scroll_speed
			if l.rect_position.y < -l.get_line_height():
				lines.erase(l)
				l.queue_free()
	elif started:
		finish()


func finish():
	if not finished:
		finished = true
		do_on_finish()

func do_on_finish():
	# NOTE: This is called when the credits finish
	# - Hook up your code to return to the relevant scene here, eg...
	#get_tree().change_scene("res://scenes/MainMenu.tscn")
	pass

func add_line():
	if not credits_container or not line:
		push_error("Please set correct path to CreditsContainer")
		return
	var new_line = line.duplicate()
	new_line.text = section.pop_front()
	lines.append(new_line)
	if curr_line == 0:
		new_line.add_color_override("font_color", title_color)
		new_line.add_font_override("font", font_caption)
	else:
		new_line.add_font_override("font", font_text)
	credits_container.add_child(new_line)
	
	if section.size() > 0:
		curr_line += 1
		section_next = false
	else:
		section_next = true


func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		finish()
	if event.is_action_pressed("ui_down") and !event.is_echo():
		speed_up = true
	if event.is_action_released("ui_down") and !event.is_echo():
		speed_up = false