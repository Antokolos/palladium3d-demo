extends Node
class_name PLDStoryNode

var InkRuntime = load("res://addons/inkgd/runtime.gd")
var Story = load("res://addons/inkgd/runtime/story.gd")

# Available translations of the stories.
const AvailableLocales = ["en", "ru"]
const TagSeparator = ":"
const TagParts : int = 2
const PARTY_VAR_PREFIX : String = "party_"
const CUTSCENE_VAR_PREFIX : String = "cutscene_"
const RELATIONSHIP_VAR_PREFIX : String = "relationship_"

# Current ink story. In fact it contains the same story for all available locales; user will make choices in all these stories simultaneously.
# The key is the locale name, the value is the ink story.
# In C# it was Dictionary<String, PLDStory>
var _inkStory = Dictionary()

# Contains all ink stories for all locales. Can be used as the stories cache (all possible stories can be preloaded when the game starts).
# The key is the locale name, the value is the Dictionary whose key is the story path and the value is the story itself.
# In C# it was Dictionary<String, Dictionary<String, PLDStory>>
var _inkStories = Dictionary()

func _ready():
	call_deferred("_add_runtime")

func _exit_tree():
	call_deferred("_remove_runtime")

func _add_runtime():
	InkRuntime.init(get_tree().root)
	for locale in AvailableLocales:
		var storiesByLocale = Dictionary() # new Dictionary<String, PLDStory>();
		_inkStories[locale] = storiesByLocale
	make_slot_dirs(0)
	make_slot_dirs(1)
	make_slot_dirs(2)
	make_slot_dirs(3)
	make_slot_dirs(4)
	make_slot_dirs(5)
	build_stories_cache("res://ink-scripts")

func _remove_runtime():
	InkRuntime.deinit(get_tree().root)

func make_slot_dirs(i : int) -> void:
	var dir : Directory = Directory.new()
	var basePath : String = "user://saves/slot_%d/ink-scripts/" % i
	dir.make_dir_recursive(basePath)
	for locale in AvailableLocales:
		dir.make_dir_recursive(basePath + ("%s/player" % locale))
		dir.make_dir_recursive(basePath + ("%s/female" % locale))
		dir.make_dir_recursive(basePath + ("%s/bandit" % locale))

func build_stories_cache(storiesDirectoryPath : String) -> void:
	for locale in AvailableLocales:
		if not _inkStories.has(locale):
			continue
		build_stories_cache_for_locale(storiesDirectoryPath, locale, "", _inkStories[locale])

func build_stories_cache_for_locale(storiesDirectoryPath : String, locale : String, subPath : String, storiesByLocale : Dictionary) -> void:
	var dir : Directory = Directory.new()
	var basePath : String = storiesDirectoryPath + "/" + locale + ("" if subPath.empty() else "/" + subPath)
	dir.open(basePath)
	dir.list_dir_begin(true)
	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif dir.current_is_dir():
			build_stories_cache_for_locale(storiesDirectoryPath, locale, file, storiesByLocale)
		elif file.ends_with(".ink.json"):
			var storyPath = basePath + "/" + file
			var story = load_story_from_file(storyPath)
			# TODO: restore story log from save
			var chatDriven : bool = false # TODO: restore chatDriven from save
			var palladiumStory : PLDStory = PLDStory.new(story, chatDriven)
			load_save_or_reset(0, locale, storyPath, palladiumStory)
			storiesByLocale[("" if subPath.empty() else subPath + "/") + file] = palladiumStory
	dir.list_dir_end()

func load_story_from_file(path : String): # Story
	var text : String = ""
	var file : File = File.new()
	if file.file_exists(path):
		file.open(path, File.READ)
		text = file.get_as_text()
		file.close()
	return Story.new(text)

# Very similar to LoadStory, but does not change the _inkStory
func check_story_not_finished(storiesDirectoryPath : String, storyPath : String) -> bool:
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
			var path : String = storiesDirectoryPath + "/" + locale + "/" + storyPath
			var story = load_story_from_file(path) # Story
			var chatDriven : bool = false # TODO: restore chatDriven from save
			var palladiumStory : PLDStory = PLDStory.new(story, chatDriven)
			load_save_or_reset(0, locale, path, palladiumStory)
			storiesByLocale[storyPath] = palladiumStory
			result = result and (story.can_continue or not story.current_choices.empty())
	return result

func load_story(storiesDirectoryPath : String, storyPath : String, chatDriven : bool, repeatable : bool) -> void:
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
			var path : String = storiesDirectoryPath + "/" + locale + "/" + storyPath
			var story = load_story_from_file(path) # Story
			var palladiumStory : PLDStory = PLDStory.new(story, chatDriven)
			load_save_or_reset(0, locale, path, palladiumStory)
			storiesByLocale[storyPath] = palladiumStory
			_inkStory[locale] = palladiumStory
		if repeatable:
			_inkStory[locale].reset_state()

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

func init_variables() -> void:
	var storyVars : Dictionary = game_state.story_vars
	var keys = storyVars.keys()
	var party_keys = game_state.get_name_hints()
	for locale in AvailableLocales:
		if _inkStory.has(locale):
			var palladiumStory : PLDStory = _inkStory[locale]
			var story = palladiumStory.get_ink_story() # Story
			for key in keys:
				if story.variables_state.global_variable_exists_with_name(key):
					story.variables_state.set(key, storyVars[key])
					story.remove_variable_observer(self, "_observe_variable", key)
					story.observe_variable(key, self, "_observe_variable")
			for party_key in party_keys:
				var story_key : String = PARTY_VAR_PREFIX + party_key
				var cutscene_key : String = CUTSCENE_VAR_PREFIX + party_key
				var relationship_key : String = RELATIONSHIP_VAR_PREFIX + party_key
				if story.variables_state.global_variable_exists_with_name(story_key):
					story.variables_state.set(story_key, game_state.is_in_party(party_key))
					story.remove_variable_observer(self, "_observe_party", story_key)
					story.observe_variable(story_key, self, "_observe_party")
				if story.variables_state.global_variable_exists_with_name(cutscene_key):
					story.variables_state.set(cutscene_key, 0)  # No cutscene by default, the cutscene will be activated during dialogue if it will be set to value > 0
					story.remove_variable_observer(self, "_observe_cutscene", cutscene_key)
					story.observe_variable(cutscene_key, self, "_observe_cutscene")
				if story.variables_state.global_variable_exists_with_name(relationship_key):
					story.variables_state.set(relationship_key, game_state.get_character(party_key).get_relationship())
					story.remove_variable_observer(self, "_observe_relationship", relationship_key)
					story.observe_variable(relationship_key, self, "_observe_relationship")

func reset() -> void:
	for locale in AvailableLocales:
		if _inkStory.has(locale):
			var palladiumStory : PLDStory = _inkStory[locale]
			var story = palladiumStory.get_ink_story() # Story
			story.reset_state()

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

func get_save_file_path(slot : int, locale : String, storyPath : String) -> String:
	return "user://saves/slot_%d/ink-scripts/%s/%s.sav" % [ slot, locale, storyPath ]

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

# Saves all stories from the _inkStories dictionary. Each one will create its own file in the user's profile folder.
func save_all(slot : int) -> void:
	for locale in _inkStories:
		var storiesByLocale : Dictionary = _inkStories[locale] # Dictionary<String, PLDStory>
		for path in storiesByLocale:
			var palladiumStory : PLDStory = storiesByLocale[path]
			var story = palladiumStory.get_ink_story() # Story
			var savedJson : String = story.state.to_json()
			var saveFile : File = File.new()
			saveFile.open(get_save_file_path(slot, locale, path), File.WRITE)
			saveFile.store_string(savedJson)
			saveFile.close()
	var slotCaptionFile : File = File.new()
	slotCaptionFile.open(get_slot_caption_file_path(slot), File.WRITE)
	slotCaptionFile.store_string(datetime_as_string(OS.get_datetime()))
	slotCaptionFile.close()

func load_save_or_reset(slot : int, locale : String, path : String, palladiumStory : PLDStory) -> bool:
	var story = palladiumStory.get_ink_story() # Story
	var saveFile : File = File.new()
	var saveFilePath : String = get_save_file_path(slot, locale, path)
	if saveFile.file_exists(saveFilePath):
		saveFile.open(saveFilePath, File.READ)
		var savedJson : String = saveFile.get_as_text()
		saveFile.close();
		story.state.load_json(savedJson)
		return true
	else:
		story.reset_state()
	return false

# Reloads state of all stories from the _inkStories dictionary from the save file.
func reload_all_saves(slot : int) -> void:
	for locale in _inkStories:
		var storiesByLocale : Dictionary = _inkStories[locale] # Dictionary<String, PLDStory>
		for path in storiesByLocale:
			var palladiumStory : PLDStory = storiesByLocale[path]
			load_save_or_reset(slot, locale, path, palladiumStory)

func can_continue() -> bool:
	for locale in AvailableLocales:
		if _inkStory.has(locale):
			var palladiumStory : PLDStory = _inkStory[locale]
			var story = palladiumStory.get_ink_story() # Story
			if not story.can_continue:
				return false
	return true

func update_log(palladiumStory : PLDStory, locale : String, text : String, choiceResponse : bool) -> void:
	var fullLog : String = ""
	var story_log = palladiumStory.get_story_log()
	if story_log.has(locale):
		fullLog = story_log[locale]
		story_log.erase(locale)
	var currentLog : String = "[right]" if choiceResponse else ""
	currentLog += str(OS.get_datetime()) + "\n";
	currentLog += text + ("[/right]\n" if choiceResponse else "\n")
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
			update_log(palladiumStory, loc, text, choiceResponse)
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
