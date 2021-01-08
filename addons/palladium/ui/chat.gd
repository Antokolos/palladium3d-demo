extends Panel

onready var chat_window = get_node('VBoxContainer/ChatWindow')
onready var info_label = get_node('VBoxContainer/InfoLabel')

var in_choice = false
var max_choice = 0

func load_chat():
	story_node.load_story("Chat.ink.json", true, false)
	story_node.init_variables()
	chat_window.bbcode_text = story_node.current_log(TranslationServer.get_locale())
	if story_node.chat_driven() and story_node.can_choose():
		display_choices()
	continue_story(0)

func _input(event):
	if self.is_visible_in_tree():
		if not story_node.chat_driven():
			return
		continue_story(get_option_number(event))

func get_option_number(event):
	if event.is_action_pressed("dialogue_next"):
		return 0
	elif event.is_action_pressed("dialogue_option_1"):
		return 1
	elif event.is_action_pressed("dialogue_option_2"):
		return 2
	elif event.is_action_pressed("dialogue_option_3"):
		return 3
	elif event.is_action_pressed("dialogue_option_4"):
		return 4
	else:
		return -1

func continue_story(option_number):
	if option_number < 0:
		return
	if story_node.can_continue() and option_number == 0:
		story_proceed(false)
		if story_node.can_choose():
			display_choices()
	elif story_node.can_choose() and option_number > 0:
		story_choose(option_number - 1)

func story_proceed(choice_response):
	story_node.continue(choice_response)
	chat_window.bbcode_text = story_node.current_log(TranslationServer.get_locale())
	info_label.text = "...typing..." if story_node.can_continue() else ""
	in_choice = false
	if story_node.can_continue():
		# TODO: Create a phrase timer so that next phrase appear after delay, simulating real typing
		continue_story(0)

func story_choose(idx):
	if idx < max_choice:
		story_node.choose(idx)
		story_proceed(true)

func display_choices():
	in_choice = true
	var ch = story_node.get_choices(TranslationServer.get_locale())
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
