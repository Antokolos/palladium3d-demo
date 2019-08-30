using Godot;
using System;
using System.Collections.Generic;
using Ink.Runtime;

public class StoryNode : Node
{
	private static String[] AvailableLocales = {"en", "ru"};
	private Story _inkStory; // = new Dictionary<String, Story>();
	private Dictionary<String, Dictionary<String, Story>> stories = new Dictionary<String, Dictionary<String, Story>>();

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
			stories.Add(locale, storiesByLocale);
			BuildStoriesCacheForLocale(storiesDirectoryPath, locale, "", storiesByLocale);
		}
	}

	public void BuildStoriesCacheForLocale(String storiesDirectoryPath, String locale, String subPath, Dictionary<String, Story> storiesByLocale)
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

	public void LoadStory(String storiesDirectoryPath, String locale, String storyPath)
	{
		Dictionary<String, Story> storiesByLocale;
		if (!stories.TryGetValue(locale, out storiesByLocale))
		{
			return;
		}
		Story mapValue;
		if (storiesByLocale.TryGetValue(storyPath, out mapValue))
		{
			_inkStory = mapValue;
		}
		else
		{
			String path = storiesDirectoryPath + "/" + locale + "/" + storyPath;
			_inkStory = LoadStoryFromFile(path);
			LoadSaveOrReset(0, locale, path, _inkStory);
			storiesByLocale.Add(storyPath, _inkStory);
		}
	}

	public void Reset()
	{
		_inkStory.ResetState();
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

	// Saves all stories from the stories dictionary. Each one will create its own file in the user's profile folder.
	public void SaveAll(int slot)
	{
		foreach (var pair in stories)
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

	// Reloads state of all stories from the stories dictionary from the save file.
	public void ReloadAllSaves(int slot)
	{
		foreach (var pair in stories)
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
		return _inkStory.canContinue;
	}

	public String Continue()
	{
		return _inkStory.Continue();
	}

	public String CurrentText()
	{
		return _inkStory.currentText;
	}

	public bool CanChoose()
	{
		return (_inkStory.currentChoices.Count > 0);
	}

	public bool Choose(int i)
	{
		if ( i >= _inkStory.currentChoices.Count || i < 0)
			return false;

		_inkStory.ChooseChoiceIndex(i);
		return true;
	}
	
	public String[] GetCurrentTags()
	{
		return _inkStory.currentTags.ToArray();
	}

	public String[] GetChoices()
	{
		var ret = new String[_inkStory.currentChoices.Count];
		for (int i = 0; i < _inkStory.currentChoices.Count; ++i) {
			Choice choice = _inkStory.currentChoices [i];
			ret[i] = choice.text;
		}

		return ret;
	}

}
