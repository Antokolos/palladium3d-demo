extends Node

var conversation_active
var conversation_target
var max_choice = 0

func _ready():
	conversation_active = false
	conversation_target = null

func change_stretch_ratio(conversation):
	var conversation_text_prev = conversation.get_node("VBox/VBoxText/HBoxTextPrev/ConversationText")
	var conversation_text = conversation.get_node("VBox/VBoxText/HBoxText/ConversationText")
	var stretch_ratio = 7
	conversation_text_prev.set("size_flags_stretch_ratio", stretch_ratio)
	conversation_text.set("size_flags_stretch_ratio", stretch_ratio)

func stop_conversation(player):
	if conversation_active:
		story_choose(player, max_choice - 1)
	conversation_active = false
	player.get_node("HUD/hud/Conversation").visible = false
	player.get_node("HUD/hud/Hints").visible = true

func start_conversation(player, target, conversation_name):
	conversation_active = true
	conversation_target = target
	player.get_node("HUD/hud/Hints").visible = false
	var conversation = player.get_node("HUD/hud/Conversation")
	conversation.visible = true
	max_choice = 0
	var story = conversation.get_node('StoryNode')
	var f = File.new()
	var cp_player = "ink-scripts/%s/%s.ink.json" % [player.name_hint, conversation_name]
	var cp = "ink-scripts/%s.ink.json" % conversation_name
	story.LoadStory(cp_player if f.file_exists(cp_player) else (cp if f.file_exists(cp) else "ink-scripts/Monsieur.ink.json"))
	story.Reset()
	var conversation_actor_prev = conversation.get_node("VBox/VBoxText/HBoxTextPrev/ActorName")
	conversation_actor_prev.text = ""
	var conversation_text_prev = conversation.get_node("VBox/VBoxText/HBoxTextPrev/ConversationText")
	conversation_text_prev.text = ""
	story_proceed(player)

func story_choose(player, idx):
	var conversation = player.get_node("HUD/hud/Conversation")
	var story = conversation.get_node('StoryNode')
	if story.CanChoose() and max_choice > 0 and idx < max_choice:
		var ch = story.GetChoices()
		var conversation_actor_prev = conversation.get_node("VBox/VBoxText/HBoxTextPrev/ActorName")
		conversation_actor_prev.text = player.name_hint + ": "
		var conversation_text_prev = conversation.get_node("VBox/VBoxText/HBoxTextPrev/ConversationText")
		conversation_text_prev.text = ch[idx]
		story.Choose(idx)
		story_proceed(player)

func story_proceed(player):
	var conversation = player.get_node("HUD/hud/Conversation")
	var story = conversation.get_node('StoryNode')
	var conversation_text = conversation.get_node("VBox/VBoxText/HBoxText/ConversationText")
	conversation_text.text = ""
	while story.CanContinue():
		conversation_text.text = conversation_text.text + " " + story.Continue()
	conversation_text.text = conversation_text.text.strip_edges()
	var conversation_actor = conversation.get_node("VBox/VBoxText/HBoxText/ActorName")
	conversation_actor.text = conversation_target.name_hint  + ": " if conversation_target and not conversation_text.text.empty() else ""
	change_stretch_ratio(conversation)
	if story.CanChoose():
		display_choices(story, conversation)
	else:
		stop_conversation(player)

func display_choices(story, conversation):
	var ch = story.GetChoices()
	var choices = conversation.get_node("VBox/VBoxChoices").get_children()
	var i = 1
	for c in choices:
		c.text = str(i) + ". " + ch[i - 1] if i <= ch.size() else ""
		i += 1
	max_choice = i - 1
