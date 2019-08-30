extends Panel

onready var story = get_node('StoryNode')
onready var chat_window = get_node('VBoxContainer/ChatWindow')
onready var info_label = get_node('VBoxContainer/InfoLabel')

var in_choice = false
var max_choice = 0
var chat_log = ""

func _ready():
	story.LoadStory("ink-scripts", TranslationServer.get_locale(), "Monsieur.ink.json")

func _unhandled_input(event):
	if self.is_visible_in_tree() and event is InputEventKey:
		if story.CanContinue() and event.is_pressed() and event.scancode == KEY_SPACE:
			story_proceed(false)
			if story.CanChoose():
				display_choices()
		elif story.CanChoose() and event.is_pressed() and event.scancode == KEY_1:
			story_choose(0)
		elif story.CanChoose() and event.is_pressed() and event.scancode == KEY_2:
			story_choose(1)
		elif story.CanChoose() and event.is_pressed() and event.scancode == KEY_3:
			story_choose(2)
		elif story.CanChoose() and event.is_pressed() and event.scancode == KEY_4:
			story_choose(3)
		elif story.CanChoose() and event.is_pressed() and event.scancode == KEY_5:
			story_choose(4)
		elif story.CanChoose() and event.is_pressed() and event.scancode == KEY_6:
			story_choose(5)
		elif story.CanChoose() and event.is_pressed() and event.scancode == KEY_7:
			story_choose(6)
		elif story.CanChoose() and event.is_pressed() and event.scancode == KEY_8:
			story_choose(7)
		elif story.CanChoose() and event.is_pressed() and event.scancode == KEY_9:
			story_choose(8)

func story_proceed(choice_response):
	var timeDict = OS.get_time();
	var hour = timeDict.hour;
	var minute = timeDict.minute;
	var seconds = timeDict.second;
	var phrase = "%02d:%02d:%02d\n" % [hour, minute, seconds] + story.Continue()
	var text = "[right]%s[/right]\n" % phrase if choice_response else phrase + "\n"
	chat_log = chat_log + text
	chat_window.bbcode_text = chat_log
	info_label.text = "...typing..." if story.CanContinue() else ""
	in_choice = false

func story_choose(idx):
	if idx < max_choice:
		story.Choose(idx)
		story_proceed(true)

func display_choices():
	in_choice = true
	var ch = story.GetChoices()
	var i = 1
	info_label.text = ""
	for c in ch:
		chat_window.push_meta(i - 1)
		chat_window.append_bbcode("[right]%s [%d]" % [c, i] + "[/right]")
		chat_window.pop()
		i += 1
	max_choice = i - 1

func _on_ChatWindow_meta_clicked(meta):
	story_choose(meta)
