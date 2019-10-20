extends Panel

onready var chat_window = get_node('VBoxContainer/ChatWindow')
onready var info_label = get_node('VBoxContainer/InfoLabel')

var in_choice = false
var max_choice = 0
var chat_log = ""

func load_chat():
	StoryNode.LoadStory("ink-scripts", "Monsieur.ink.json")
	StoryNode.InitVariables(game_params.story_vars)
	if chat_log.empty() and StoryNode.CanChoose():
		display_choices()

func _unhandled_input(event):
	if self.is_visible_in_tree() and event is InputEventKey:
		if StoryNode.CanContinue() and event.is_pressed() and event.scancode == KEY_SPACE:
			story_proceed(false)
			if StoryNode.CanChoose():
				display_choices()
		elif StoryNode.CanChoose() and event.is_pressed() and event.scancode == KEY_1:
			story_choose(0)
		elif StoryNode.CanChoose() and event.is_pressed() and event.scancode == KEY_2:
			story_choose(1)
		elif StoryNode.CanChoose() and event.is_pressed() and event.scancode == KEY_3:
			story_choose(2)
		elif StoryNode.CanChoose() and event.is_pressed() and event.scancode == KEY_4:
			story_choose(3)
		elif StoryNode.CanChoose() and event.is_pressed() and event.scancode == KEY_5:
			story_choose(4)
		elif StoryNode.CanChoose() and event.is_pressed() and event.scancode == KEY_6:
			story_choose(5)
		elif StoryNode.CanChoose() and event.is_pressed() and event.scancode == KEY_7:
			story_choose(6)
		elif StoryNode.CanChoose() and event.is_pressed() and event.scancode == KEY_8:
			story_choose(7)
		elif StoryNode.CanChoose() and event.is_pressed() and event.scancode == KEY_9:
			story_choose(8)

func story_proceed(choice_response):
	var timeDict = OS.get_time();
	var hour = timeDict.hour;
	var minute = timeDict.minute;
	var seconds = timeDict.second;
	var phrase = "%02d:%02d:%02d\n" % [hour, minute, seconds] + StoryNode.Continue(TranslationServer.get_locale())
	var text = "[right]%s[/right]\n" % phrase if choice_response else phrase + "\n"
	chat_log = chat_log + text
	chat_window.bbcode_text = chat_log
	info_label.text = "...typing..." if StoryNode.CanContinue() else ""
	in_choice = false

func story_choose(idx):
	if idx < max_choice:
		StoryNode.Choose(idx)
		story_proceed(true)

func display_choices():
	in_choice = true
	var ch = StoryNode.GetChoices(TranslationServer.get_locale())
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
