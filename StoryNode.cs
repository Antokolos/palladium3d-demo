using Godot;
using System;
using System.Collections.Generic;
using Ink.Runtime;

public class StoryNode : Node
{
	/// Available translations of the stories.
	private static String[] AvailableLocales = {"en", "ru"};
	/// Current ink story. In fact it contains the same story for all available locales; user will make choices in all these stories simultaneously.
	/// The key is the locale name, the value is the ink story.
	private Dictionary<String, Story> _inkStory = new Dictionary<String, Story>();
	/// Contains all ink stories for all locales. Can be used as the stories cache (all possible stories can be preloaded when the game starts).
	/// The key is the locale name, the value is the Dictionary whose key is the story path and the value is the story itself.
	private Dictionary<String, Dictionary<String, Story>> _inkStories = new Dictionary<String, Dictionary<String, Story>>();

	public override void _Ready()
	{
		MakeSaveSlotDirs(0);
		MakeSaveSlotDirs(1);
		MakeSaveSlotDirs(2);
		MakeSaveSlotDirs(3);
		MakeSaveSlotDirs(4);
		MakeSaveSlotDirs(5);
	}

	private void MakeSaveSlotDirs(int i)
	{
		Directory dir = new Directory();
		dir.MakeDir("user://saves");
		string basePath = string.Format("user://saves/slot_{0}", i);
		dir.MakeDir(basePath);
		dir.MakeDir(basePath + "/ink-scripts");
		foreach (var locale in AvailableLocales)
		{
			dir.MakeDir(string.Format("{0}/ink-scripts/{1}", basePath, locale));
			dir.MakeDir(string.Format("{0}/ink-scripts/{1}/player", basePath, locale));
			dir.MakeDir(string.Format("{0}/ink-scripts/{1}/female", basePath, locale));
		}
	}

	public void BuildStoriesCache(String storiesDirectoryPath)
	{
		foreach (var locale in AvailableLocales)
		{
			var storiesByLocale = new Dictionary<String, Story>();
			_inkStories.Add(locale, storiesByLocale);
			BuildStoriesCacheForLocale(storiesDirectoryPath, locale, "", storiesByLocale);
		}
	}

	private void BuildStoriesCacheForLocale(String storiesDirectoryPath, String locale, String subPath, Dictionary<String, Story> storiesByLocale)
	{
		var dir = new Directory();
		String basePath = storiesDirectoryPath + "/" + locale + (subPath.Empty() ? "" : "/" + subPath);
		dir.Open(basePath);
		dir.ListDirBegin(true);
		while (true)
		{
			var file = dir.GetNext();
			if (file == "")
			{
				break;
			}
			else if (dir.CurrentIsDir())
			{
				BuildStoriesCacheForLocale(storiesDirectoryPath, locale, file, storiesByLocale);
			}
			else if (file.EndsWith(".ink.json"))
			{
				var storyPath = basePath + "/" + file;
				Story story = LoadStoryFromFile(storyPath);
				LoadSaveOrReset(0, locale, storyPath, story);
				storiesByLocale.Add((subPath.Empty() ? "" : subPath + "/") + file, story);
			}
		}
		dir.ListDirEnd();
	}

	private Story LoadStoryFromFile(String path)
	{
		String text = System.IO.File.ReadAllText(path);
		return new Story(text);
	}

	public void LoadStory(String storiesDirectoryPath, String storyPath)
	{
		_inkStory = new Dictionary<String, Story>();
		foreach (var locale in AvailableLocales)
		{
			Dictionary<String, Story> storiesByLocale;
			if (!_inkStories.TryGetValue(locale, out storiesByLocale))
			{
				continue;
			}
			Story mapValue;
			if (storiesByLocale.TryGetValue(storyPath, out mapValue))
			{
				_inkStory.Add(locale, mapValue);
			}
			else
			{
				String path = storiesDirectoryPath + "/" + locale + "/" + storyPath;
				Story story = LoadStoryFromFile(path);
				LoadSaveOrReset(0, locale, path, story);
				storiesByLocale.Add(storyPath, story);
				_inkStory.Add(locale, story);
			}
		}
	}

	public void Reset()
	{
		foreach (var locale in AvailableLocales)
		{
			Story story;
			if (_inkStory.TryGetValue(locale, out story))
			{
				story.ResetState();
			}
		}
	}

	private String GetSlotCaptionFilePath(int slot)
	{
		return string.Format("user://saves/slot_{0}/caption", slot);
	}

	public String GetSlotCaption(int slot)
	{
		String result = "";
		File slotCaptionFile = new File();
		String slotCaptionFilePath = GetSlotCaptionFilePath(slot);
		if (slotCaptionFile.FileExists(slotCaptionFilePath))
		{
			slotCaptionFile.Open(slotCaptionFilePath, 1); // File.ModeFlags.READ
			result = slotCaptionFile.GetAsText();
			slotCaptionFile.Close();
		}
		return result;
	}

	private String GetSaveFilePath(int slot, String locale, String storyPath)
	{
		return string.Format("user://saves/slot_{0}/ink-scripts/{1}/{2}.sav", slot, locale, storyPath);
	}

	/// Saves all stories from the _inkStories dictionary. Each one will create its own file in the user's profile folder.
	public void SaveAll(int slot)
	{
		foreach (var pair in _inkStories)
		{
			String locale = pair.Key;
			Dictionary<String, Story> storiesByLocale = pair.Value;
			foreach (var pairStories in storiesByLocale)
			{
				String path = pairStories.Key;
				Story story = pairStories.Value;
				string savedJson = story.state.ToJson();
				File saveFile = new File();
				saveFile.Open(GetSaveFilePath(slot, locale, path), 2); // File.ModeFlags.WRITE
				saveFile.StoreString(savedJson);
				saveFile.Close();
			}
		}
		File slotCaptionFile = new File();
		slotCaptionFile.Open(GetSlotCaptionFilePath(slot), 2); // File.ModeFlags.WRITE
		slotCaptionFile.StoreString(DateTime.Now.ToString());
		slotCaptionFile.Close();
	}

	private bool LoadSaveOrReset(int slot, String locale, String path, Story story)
	{
		File saveFile = new File();
		String saveFilePath = GetSaveFilePath(slot, locale, path);
		if (saveFile.FileExists(saveFilePath))
		{
			saveFile.Open(saveFilePath, 1); // File.ModeFlags.READ
			String savedJson = saveFile.GetAsText();
			saveFile.Close();
			story.state.LoadJson(savedJson);
			return true;
		}
		else
		{
			story.ResetState();
		}
		return false;
	}

	/// Reloads state of all stories from the _inkStories dictionary from the save file.
	public void ReloadAllSaves(int slot)
	{
		foreach (var pair in _inkStories)
		{
			String locale = pair.Key;
			Dictionary<String, Story> storiesByLocale = pair.Value;
			foreach (var pairStories in storiesByLocale)
			{
				String path = pairStories.Key;
				Story story = pairStories.Value;
				LoadSaveOrReset(slot, locale, path, story);
			}
		}
	}

	public bool CanContinue()
	{
		foreach (var locale in AvailableLocales)
		{
			Story story;
			if (_inkStory.TryGetValue(locale, out story))
			{
				if (!story.canContinue)
				{
					return false;
				}
			}
		}
		return true;
	}

	public String Continue(String locale)
	{
		String result = "";
		foreach (var loc in AvailableLocales)
		{
			Story story;
			if (_inkStory.TryGetValue(loc, out story))
			{
				String text = story.Continue();
				if (loc == locale)
				{
					result = text;
				}
			}
		}
		return result;
	}

	public Godot.Collections.Dictionary<String, String> ContinueWhileYouCan()
	{
		Godot.Collections.Dictionary<String, String> result = new Godot.Collections.Dictionary<String, String>();
		foreach (var loc in AvailableLocales)
		{
			Story story;
			if (_inkStory.TryGetValue(loc, out story))
			{
				String text = "";
				while (story.canContinue)
				{
					text = text + " " + story.Continue();
				}
				result.Add(loc, text);
			}
		}
		return result;
	}

	public String CurrentText(String locale)
	{
		Story story;
		if (_inkStory.TryGetValue(locale, out story))
		{
			return story.currentText;
		}
		return "";
	}

	public bool CanChoose()
	{
		foreach (var locale in AvailableLocales)
		{
			Story story;
			if (_inkStory.TryGetValue(locale, out story))
			{
				if (story.currentChoices.Count <= 0)
				{
					return false;
				}
			}
		}
		return true;
	}

	public bool Choose(int i)
	{
		bool success = true;
		foreach (var locale in AvailableLocales)
		{
			Story story;
			if (_inkStory.TryGetValue(locale, out story))
			{
				success = success && (i >= 0 && i < story.currentChoices.Count);
				if (success)
				{
					story.ChooseChoiceIndex(i);
				}
			}
		}
		return success;
	}
	
	public Godot.Collections.Dictionary<String, String[]> GetCurrentTags()
	{
		Godot.Collections.Dictionary<String, String[]> result = new Godot.Collections.Dictionary<String, String[]>();
		foreach (var locale in AvailableLocales)
		{
			result.Add(locale, GetCurrentTags(locale));
		}
		return result;
	}
	
	public String[] GetCurrentTags(String locale)
	{
		Story story;
		if (_inkStory.TryGetValue(locale, out story))
		{
			return story.currentTags.ToArray();
		}
		return new String[0];
	}

	public String[] GetChoices(String locale)
	{
		Story story;
		if (_inkStory.TryGetValue(locale, out story))
		{
			var ret = new String[story.currentChoices.Count];
			for (int i = 0; i < story.currentChoices.Count; ++i) {
				Choice choice = story.currentChoices [i];
				ret[i] = choice.text;
			}
			return ret;
		}
		return new String[0];
	}

}
