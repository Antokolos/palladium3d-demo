extends Node
class_name PLDStoryNode

var InkRuntime = load("res://addons/inkgd/runtime.gd")
var Story = load("res://addons/inkgd/runtime/story.gd")

const INK_SCRIPTS_DIR = "res://ink-scripts"
# Available translations of the stories.
const AvailableLocales = ["en", "ru"]
const TagSeparator = ":"
const TagParts : int = 2
const PARTY_VAR_PREFIX : String = "party_"
const CUTSCENE_VAR_PREFIX : String = "cutscene_"
const RELATIONSHIP_VAR_PREFIX : String = "relationship_"
const MORALE_VAR_PREFIX : String = "morale_"
const RESULT_VAR_NAME : String = "result"

# Current ink story. In fact it contains the same story for all available locales; user will make choices in all these stories simultaneously.
# The key is the locale name, the value is the ink story.
# In C# it was Dictionary<String, PLDStory>
var _inkStory = Dictionary()

# Contains all ink stories for all locales. Can be used as the stories cache (all possible stories can be preloaded when the game starts).
# The key is the locale name, the value is the Dictionary whose key is the story path and the value is the story itself.
# In C# it was Dictionary<String, Dictionary<String, PLDStory>>
var _inkStories = Dictionary()

# Contains saved states for all ink stories for all locales.
# The key is the locale name, the value is the Dictionary whose key is the story path and the value is the story state as json.
# This map is updated when the game is saved.
var _inkStoriesStates = Dictionary()

# Contains stories that were changed during the current session.
# The key is the locale name, the value is the Dictionary whose key is the story path and the value is the corresponding story.
# States of these stories should be converted to json before save.
# This map will be cleared when the game is saved.
var _currentSessionStories = Dictionary()

var last_result : int = 0

func _ready():
	call_deferred("_add_runtime")

func _exit_tree():
	call_deferred("_remove_runtime")

func _add_runtime():
	InkRuntime.init(get_tree().root)
	for locale in AvailableLocales:
		_inkStories[locale] = Dictionary() # new Dictionary<String, PLDStory>();
		_inkStoriesStates[locale] = Dictionary()
		_currentSessionStories[locale] = Dictionary()
	make_slot_dirs(0)
	make_slot_dirs(1)
	make_slot_dirs(2)
	make_slot_dirs(3)
	make_slot_dirs(4)
	make_slot_dirs(5)
	build_stories_cache(-1, INK_SCRIPTS_DIR)

func _remove_runtime():
	InkRuntime.deinit(get_tree().root)

func make_slot_dirs(i : int) -> void:
	var dir : Directory = Directory.new()
	for locale in AvailableLocales:
		var basePath : String = "user://saves/slot_%d/ink-scripts/%s" % [ i, locale ]
		dir.make_dir_recursive(basePath)

func build_stories_cache(slot : int, storiesDirectoryPath : String) -> void:
	for locale in AvailableLocales:
		if not _inkStories.has(locale):
			continue
		_inkStories[locale].clear()
		build_stories_cache_for_locale(slot, storiesDirectoryPath, locale, "", _inkStories[locale])

func build_stories_cache_for_locale(slot : int, storiesDirectoryPath : String, locale : String, subPath : String, storiesByLocale : Dictionary) -> void:
	var dir : Directory = Directory.new()
	var basePath : String = storiesDirectoryPath + "/" + locale + ("" if subPath.empty() else "/" + subPath)
	dir.open(basePath)
	dir.list_dir_begin(true)
	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif dir.current_is_dir():
			build_stories_cache_for_locale(slot, storiesDirectoryPath, locale, file, storiesByLocale)
		elif file.ends_with(".ink.json"):
			var storyName : String = ("" if subPath.empty() else subPath + "/") + file
			var storyPath : String = basePath + "/" + file
			var story = load_story_from_file(storyPath)
			bind_external_functions(story)
			# TODO: Probably we need to support multiple chat driven stories?
			var chatDriven : bool = (file == "Chat.ink.json")
			var palladiumStory : PLDStory = PLDStory.new(story, storiesDirectoryPath, locale, storyName, chatDriven)
			load_save_or_reset(slot, palladiumStory)
			storiesByLocale[("" if subPath.empty() else subPath + "/") + file] = palladiumStory
	dir.list_dir_end()

func bind_external_functions(story):
	story.bind_external_function("is_untouched", game_state, "_is_untouched")
	story.bind_external_function("is_activated", game_state, "_is_activated")
	story.bind_external_function("is_deactivated", game_state, "_is_deactivated")
	story.bind_external_function("is_paused", game_state, "_is_paused")
	story.bind_external_function("is_final_destination", game_state, "_is_final_destination")
	story.bind_external_function("is_actual", game_state, "_is_actual")

func load_story_from_file(path : String): # Story
	var text : String = ""
	var file : File = File.new()
	if file.file_exists(path):
		file.open(path, File.READ)
		text = file.get_as_text()
		file.close()
	return Story.new(text)

# Very similar to load_story(), but does not change the _inkStory
func check_story_not_finished(storyPath : String) -> bool:
	var result : bool = true
	for locale in AvailableLocales:
		if not _inkStories.has(locale):
			continue
		var storiesByLocale : Dictionary = _inkStories[locale] # Dictionary<String, PLDStory>
		if storiesByLocale.has(storyPath):
			var ps : PLDStory = storiesByLocale[storyPath]
			var story = ps.get_ink_story() # Story
			result = result and (story.can_continue or not story.current_choices.empty())
		else:
			push_error("Story '%s' for locale '%s' was not found in cache")
			return true
	return result

func load_story(storyPath : String, chatDriven : bool, repeatable : bool) -> void:
	for locale in AvailableLocales:
		if _inkStory.has(locale):
			_inkStory.erase(locale)
		if not _inkStories.has(locale):
			continue;
		var storiesByLocale : Dictionary = _inkStories[locale] # Dictionary<String, PLDStory>
		if storiesByLocale.has(storyPath):
			var cachedPalladiumStory : PLDStory = storiesByLocale[storyPath]
			cachedPalladiumStory.set_chat_driven(chatDriven)
			_inkStory[locale] = cachedPalladiumStory
		else:
			push_error("Story '%s' for locale '%s' was not found in cache")
			return
		if repeatable:
			_inkStory[locale].reset_state()
			_inkStoriesStates[locale][storyPath].story_state = ""
		_currentSessionStories[locale][storyPath] = _inkStory[locale]

func _observe_variable(variable_name, new_value) -> void:
	game_state.story_vars[variable_name] = new_value

func _observe_party(variable_name, new_value) -> void:
	var v : bool = int(new_value) > 0
	var name_hint = variable_name.substr(PARTY_VAR_PREFIX.length(), variable_name.length())
	if v and not game_state.is_in_party(name_hint):
		game_state.join_party(name_hint)
	elif not v and game_state.is_in_party(name_hint):
		game_state.leave_party(name_hint)

func _observe_cutscene(variable_name, new_value) -> void:
	var v : int = int(new_value)
	var name_hint = variable_name.substr(CUTSCENE_VAR_PREFIX.length(), variable_name.length())
	var character = game_state.get_character(name_hint)
	character.play_cutscene(v)

func _observe_relationship(variable_name, new_value) -> void:
	var v : int = int(new_value)
	var name_hint = variable_name.substr(RELATIONSHIP_VAR_PREFIX.length(), variable_name.length())
	var character = game_state.get_character(name_hint)
	character.set_relationship(v)

func _observe_morale(variable_name, new_value) -> void:
	var v : int = int(new_value)
	var name_hint = variable_name.substr(MORALE_VAR_PREFIX.length(), variable_name.length())
	var character = game_state.get_character(name_hint)
	character.set_morale(v)

func _observe_result(variable_name, new_value) -> void:
	var v : int = int(new_value)
	last_result = v

func get_last_result() -> int:
	return last_result

func init_variables() -> void:
	var storyVars : Dictionary = game_state.story_vars
	var keys = storyVars.keys()
	var party_keys = game_state.get_name_hints()
	for locale in AvailableLocales:
		var is_current_locale = (locale == TranslationServer.get_locale())
		if _inkStory.has(locale):
			var palladiumStory : PLDStory = _inkStory[locale]
			var story = palladiumStory.get_ink_story() # Story
			if story.variables_state.global_variable_exists_with_name(RESULT_VAR_NAME):
				story.variables_state.set(RESULT_VAR_NAME, 0)
				story.remove_variable_observer(self, "_observe_result", RESULT_VAR_NAME)
				if is_current_locale:
					story.observe_variable(RESULT_VAR_NAME, self, "_observe_result")
			for key in keys:
				if story.variables_state.global_variable_exists_with_name(key):
					story.variables_state.set(key, storyVars[key])
					story.remove_variable_observer(self, "_observe_variable", key)
					if is_current_locale:
						story.observe_variable(key, self, "_observe_variable")
			for party_key in party_keys:
				var story_key : String = PARTY_VAR_PREFIX + party_key
				var cutscene_key : String = CUTSCENE_VAR_PREFIX + party_key
				var relationship_key : String = RELATIONSHIP_VAR_PREFIX + party_key
				var morale_key : String = MORALE_VAR_PREFIX + party_key
				if story.variables_state.global_variable_exists_with_name(story_key):
					story.variables_state.set(story_key, game_state.is_in_party(party_key))
					story.remove_variable_observer(self, "_observe_party", story_key)
					if is_current_locale:
						story.observe_variable(story_key, self, "_observe_party")
				if story.variables_state.global_variable_exists_with_name(cutscene_key):
					story.variables_state.set(cutscene_key, 0)  # No cutscene by default, the cutscene will be activated during dialogue if it will be set to value > 0
					story.remove_variable_observer(self, "_observe_cutscene", cutscene_key)
					if is_current_locale:
						story.observe_variable(cutscene_key, self, "_observe_cutscene")
				if story.variables_state.global_variable_exists_with_name(relationship_key):
					story.variables_state.set(relationship_key, game_state.get_character(party_key).get_relationship())
					story.remove_variable_observer(self, "_observe_relationship", relationship_key)
					if is_current_locale:
						story.observe_variable(relationship_key, self, "_observe_relationship")
				if story.variables_state.global_variable_exists_with_name(morale_key):
					story.variables_state.set(morale_key, game_state.get_character(party_key).get_morale())
					story.remove_variable_observer(self, "_observe_morale", morale_key)
					if is_current_locale:
						story.observe_variable(morale_key, self, "_observe_morale")

func reset() -> void:
	for locale in AvailableLocales:
		if _inkStory.has(locale):
			var palladiumStory : PLDStory = _inkStory[locale]
			var story = palladiumStory.get_ink_story() # Story
			story.reset_state()
			_inkStoriesStates[locale][palladiumStory.get_story_name()].story_state = ""

func increase_visit_count():
	for locale in AvailableLocales:
		if _inkStory.has(locale):
			var palladiumStory : PLDStory = _inkStory[locale]
			_inkStoriesStates[locale][palladiumStory.get_story_name()].visit_count += 1

func get_slot_caption_file_path(slot : int) -> String:
	return "user://saves/slot_%d/caption" % slot

func get_slot_caption(slot : int) -> String:
	var result : String = ""
	var slotCaptionFile : File = File.new()
	var slotCaptionFilePath : String = get_slot_caption_file_path(slot)
	if slotCaptionFile.file_exists(slotCaptionFilePath):
		slotCaptionFile.open(slotCaptionFilePath, File.READ)
		result = slotCaptionFile.get_as_text()
		slotCaptionFile.close()
	return result;

func get_save_file_path(slot : int, locale : String) -> String:
	return "user://saves/slot_%d/ink-scripts/%s/story_states.sav" % [ slot, locale ]

func get_story_log_path(slot : int, story_name : String, locale : String) -> String:
	return "user://saves/slot_%d/ink-scripts/%s/%s.log" % [ slot, locale, story_name ]

func get_month_as_string(m):
	match m:
		1:
			return "Jan"
		2:
			return "Feb"
		3:
			return "Mar"
		4:
			return "Apr"
		5:
			return "May"
		6:
			return "Jun"
		7:
			return "Jul"
		8:
			return "Aug"
		9:
			return "Sep"
		10:
			return "Oct"
		11:
			return "Nov"
		12:
			return "Dec"
		_:
			return ""

func datetime_as_string(dt):
	return "%0*d %s %d, %0*d:%0*d:%0*d" % [2, dt.day, get_month_as_string(dt.month), dt.year, 2, dt.hour, 2, dt.minute, 2, dt.second]

# Saves all stories from the _inkStories dictionary.
func save_all(slot : int) -> void:
	for locale in AvailableLocales:
		for path in _currentSessionStories[locale]:
			var palladiumStory = _currentSessionStories[locale][path]
			var story = palladiumStory.get_ink_story()
			_inkStoriesStates[locale][path].story_state = story.state.to_json()
			if palladiumStory.is_chat_driven():
				var storyLogFile : File = File.new()
				storyLogFile.open(get_story_log_path(slot, path, locale), File.WRITE)
				storyLogFile.store_string(palladiumStory.get_story_log()[locale])
				storyLogFile.close()
		_currentSessionStories[locale].clear()
		var saveFile : File = File.new()
		saveFile.open(get_save_file_path(slot, locale), File.WRITE)
		saveFile.store_string(to_json(_inkStoriesStates[locale]))
		saveFile.close()
	var slotCaptionFile : File = File.new()
	slotCaptionFile.open(get_slot_caption_file_path(slot), File.WRITE)
	slotCaptionFile.store_string(datetime_as_string(OS.get_datetime()))
	slotCaptionFile.close()

func load_save_or_reset(slot : int, palladiumStory : PLDStory) -> bool:
	var locale = palladiumStory.get_locale()
	var path = palladiumStory.get_story_path()
	var story_name = palladiumStory.get_story_name()
	var story = palladiumStory.get_ink_story() # Story
	var visit_count = 0
	if slot >= 0:
		if palladiumStory.is_chat_driven():
			var storyLogFile : File = File.new()
			var storyLogFilePath : String = get_story_log_path(slot, story_name, locale)
			if storyLogFile.file_exists(storyLogFilePath):
				storyLogFile.open(storyLogFilePath, File.READ)
				var story_log = palladiumStory.get_story_log()
				if story_log.has(locale):
					story_log.erase(locale)
				story_log[locale] = storyLogFile.get_as_text()
				storyLogFile.close()
		if _inkStoriesStates[locale].empty():
			var saveFile : File = File.new()
			var saveFilePath : String = get_save_file_path(slot, locale)
			if saveFile.file_exists(saveFilePath):
				saveFile.open(saveFilePath, File.READ)
				var savedJson : String = saveFile.get_as_text()
				saveFile.close()
				var d = parse_json(savedJson)
				if (typeof(d) == TYPE_DICTIONARY):
					_inkStoriesStates[locale] = d
		if _inkStoriesStates[locale].has(story_name):
			var story_state = _inkStoriesStates[locale][story_name].story_state
			visit_count = _inkStoriesStates[locale][story_name].visit_count
			if story_state and not story_state.empty():
				story.state.load_json(story_state)
				return true
	story.reset_state()
	_inkStoriesStates[locale][story_name] = {
		"story_state" : "",
		"visit_count" : visit_count
	}
	return false

# Reloads state of all stories from the _inkStories dictionary from the save file.
func reload_all_saves(slot : int) -> void:
	for locale in AvailableLocales:
		_currentSessionStories[locale].clear()
		_inkStoriesStates[locale].clear()
		var storiesByLocale : Dictionary = _inkStories[locale] # Dictionary<String, PLDStory>
		for path in storiesByLocale:
			var palladiumStory : PLDStory = storiesByLocale[path]
			load_save_or_reset(slot, palladiumStory)

func can_continue() -> bool:
	for locale in AvailableLocales:
		if _inkStory.has(locale):
			var palladiumStory : PLDStory = _inkStory[locale]
			var story = palladiumStory.get_ink_story() # Story
			if not story.can_continue:
				return false
	return true

func update_log(palladiumStory : PLDStory, locale : String, tags : Dictionary, text : String, choiceResponse : bool) -> void:
	var fullLog : String = ""
	var story_log = palladiumStory.get_story_log()
	if story_log.has(locale):
		fullLog = story_log[locale]
		story_log.erase(locale)
	var has_actor = tags and tags.has("actor")
	var currentLog : String = "[right]" if choiceResponse else ("" if has_actor else "[center]")
	if has_actor:
		var actor = tr(tags["actor"])
		currentLog += "[color=yellow]%s[/color]\t[color=green]%s[/color]\n" % [ actor, datetime_as_string(OS.get_datetime()) ]
	currentLog += text + ("[/right]\n" if choiceResponse else ("\n" if has_actor else "[/center]\n"))
	fullLog += currentLog;
	story_log[locale] = fullLog

func continue(choiceResponse : bool) -> Dictionary: # Dictionary<String, String>
	var result : Dictionary = Dictionary() # Dictionary<String, String>
	for loc in AvailableLocales:
		if _inkStory.has(loc):
			var palladiumStory : PLDStory = _inkStory[loc]
			var story = palladiumStory.get_ink_story() # Story
			var text : String = story.continue()
			result[loc] = text
			var tags_dict = get_current_tags()
			var tags = tags_dict[loc]
			update_log(palladiumStory, loc, tags, text, choiceResponse)
	return result

func current_text(locale : String) -> String:
	if _inkStory.has(locale):
		var palladiumStory : PLDStory = _inkStory[locale]
		var story = palladiumStory.get_ink_story() # Story
		return story.current_text
	return ""

func current_log(locale : String) -> String:
	if _inkStory.has(locale):
		var palladiumStory : PLDStory = _inkStory[locale]
		var storyLog : Dictionary = palladiumStory.get_story_log() # Dictionary<String, String>
		if storyLog.has(locale):
			return storyLog[locale]
	return ""

func chat_driven() -> bool:
	for loc in AvailableLocales:
		if _inkStory.has(loc):
			var palladiumStory : PLDStory = _inkStory[loc]
			return palladiumStory.is_chat_driven()
	return false

func can_choose() -> bool:
	for locale in AvailableLocales:
		if _inkStory.has(locale):
			var palladiumStory : PLDStory = _inkStory[locale]
			var story = palladiumStory.get_ink_story() # Story
			if story.current_choices.empty():
				return false
	return true

func choose(i : int) -> bool:
	var success : bool = true
	for locale in AvailableLocales:
		if _inkStory.has(locale):
			var palladiumStory : PLDStory = _inkStory[locale]
			var story = palladiumStory.get_ink_story() # Story
			success = success and (i >= 0 and i < story.current_choices.size())
			if success:
				story.choose_choice_index(i)
	return success
	
func get_current_tags() -> Dictionary: # Dictionary<String, Dictionary<String, String>>
	var result : Dictionary = Dictionary() # Dictionary<String, Dictionary<String, String>>
	for locale in AvailableLocales:
		result[locale] = get_current_tags_for_locale(locale)
	return result

func get_current_tags_for_locale(locale : String) -> Dictionary: # Dictionary<String, String>
	var result : Dictionary = Dictionary() # Dictionary<String, String>
	if _inkStory.has(locale):
		var palladiumStory : PLDStory = _inkStory[locale]
		var story = palladiumStory.get_ink_story() # Story
		for tag in story.current_tags:
			var tagParts = tag.strip_edges().split(TagSeparator, false, TagParts)
			if tagParts.size() > 1:
				result[tagParts[0]] = tagParts[1]
			else:
				result[tagParts[0]] = ""
	return result

func get_choices(locale : String): # -> String[]
	if _inkStory.has(locale):
		var palladiumStory : PLDStory = _inkStory[locale]
		var story = palladiumStory.get_ink_story() # Story
		var ret = []
		for i in range(story.current_choices.size()):
			var choice = story.current_choices[i]
			ret.append(choice.text)
		return ret
	return []
