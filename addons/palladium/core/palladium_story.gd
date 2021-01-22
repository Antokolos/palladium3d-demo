extends Node
class_name PLDStory

# type of variable: "res://addons/inkgd/runtime/story.gd"
var _inkstory
# Stories directory path (typically 'res://ink-scripts')
var _stories_path : String
# Story locale
var _locale : String
# Story name ('example.ink.json' or 'character/example.ink.json')
var _name : String
# Story log by locale
var _storylog : Dictionary
# Story choices can be chosen in chat
var _chatdriven : bool

func _init(inkstory, stories_path : String, locale : String, name : String, chatdriven : bool):
	_inkstory = inkstory
	_storylog = Dictionary()
	_chatdriven = chatdriven
	_stories_path = stories_path
	_locale = locale
	_name = name

func reset_state():
	_inkstory.reset_state()

func get_ink_story():
	return _inkstory

func get_locale():
	return _locale

func get_story_name():
	return _name

func get_story_path():
	return _stories_path + "/" + _locale + "/" + _name

func get_story_log():
	return _storylog

func is_chat_driven():
	return _chatdriven

func set_chat_driven(chatdriven : bool):
	_chatdriven = chatdriven
