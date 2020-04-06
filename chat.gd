extends Panel

onready var chat_window = get_node('VBoxContainer/ChatWindow')
onready var info_label = get_node('VBoxContainer/InfoLabel')

var in_choice = false
var max_choice = 0

func _ready():
	StoryNode.LoadStory("ink-scripts", "Chat.ink.json", true)
	StoryNode.InitVariables(game_params, game_params.story_vars, game_params.party)

func load_chat():
	chat_window.bbcode_text = StoryNode.CurrentLog(TranslationServer.get_locale())
	if StoryNode.ChatDriven() and StoryNode.CanChoose():
		display_choices()

func _input(event):
	if self.is_visible_in_tree():
		if not StoryNode.ChatDriven():
			return
		
		if StoryNode.CanContinue() and event.is_action_pressed("dialogue_next"):
			story_proceed(false)
			if StoryNode.CanChoose():
				display_choices()
		elif StoryNode.CanChoose() and event.is_action_pressed("dialogue_option_1"):
			story_choose(0)
		elif StoryNode.CanChoose() and event.is_action_pressed("dialogue_option_2"):
			story_choose(1)
		elif StoryNode.CanChoose() and event.is_action_pressed("dialogue_option_3"):
			story_choose(2)
		elif StoryNode.CanChoose() and event.is_action_pressed("dialogue_option_4"):
			story_choose(3)

func story_proceed(choice_response):
	StoryNode.Continue(choice_response)
	chat_window.bbcode_text = StoryNode.CurrentLog(TranslationServer.get_locale())
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
