extends Node
class_name PLDStory

# type of variable: "res://addons/inkgd/runtime/story.gd"
var _inkstory
# Path to story file
var _storypath : String
# Story log by locale
var _storylog : Dictionary
# Story choices can be chosen in chat
var _chatdriven : bool

func _init(inkstory, storypath : String, chatdriven : bool):
	_inkstory = inkstory
	_storylog = Dictionary()
	_chatdriven = chatdriven
	_storypath = storypath

func reset_state():
	_inkstory.reset_state()

func get_ink_story():
	return _inkstory

func get_story_path():
	return _storypath

func get_story_log():
	return _storylog

func is_chat_driven():
	return _chatdriven

func set_chat_driven(chatdriven : bool):
	_chatdriven = chatdriven
