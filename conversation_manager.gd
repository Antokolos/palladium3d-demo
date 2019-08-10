extends Node

var conversation_active
var max_choice = 0

func _ready():
	conversation_active = false

func stop_conversation(player):
	if conversation_active:
		story_choose(player, max_choice - 1)
	conversation_active = false
	player.get_node("HUD/hud/Conversation").visible = false
	player.get_node("HUD/hud/Hints").visible = true

func start_conversation(player, conversation_path):
	conversation_active = true
	player.get_node("HUD/hud/Hints").visible = false
	var conversation = player.get_node("HUD/hud/Conversation")
	conversation.visible = true
	max_choice = 0
	var story = conversation.get_node('StoryNode')
	story.LoadStory(conversation_path)
	story.Reset()
	story_proceed(player)

func story_choose(player, idx):
	var conversation = player.get_node("HUD/hud/Conversation")
	var story = conversation.get_node('StoryNode')
	if story.CanChoose() and max_choice > 0 and idx < max_choice:
		story.Choose(idx)
		story_proceed(player)

func story_proceed(player):
	var conversation = player.get_node("HUD/hud/Conversation")
	var story = conversation.get_node('StoryNode')
	var conversation_text = conversation.get_node("HBoxContainer/VBoxContainer/ConversationText")
	conversation_text.text = ""
	while story.CanContinue():
		conversation_text.text = conversation_text.text + " " + story.Continue()
	if story.CanChoose():
		display_choices(story, conversation)
	else:
		stop_conversation(player)

func display_choices(story, conversation):
	var ch = story.GetChoices()
	var choices = conversation.get_node("HBoxContainer/VBoxContainer/VBoxContainer").get_children()
	var i = 1
	for c in choices:
		c.text = str(i) + ". " + ch[i - 1] if i <= ch.size() else ""
		i += 1
	max_choice = i - 1
