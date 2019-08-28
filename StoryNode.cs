using Godot;
using System;
using System.Collections.Generic;
using Ink.Runtime;

public class StoryNode : Node
{
	private Story _inkStory = null;
	private Dictionary<String, Story> stories = new Dictionary<String, Story>();

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
		dir.MakeDir(basePath + "/ink-scripts/player");
		dir.MakeDir(basePath + "/ink-scripts/female");
	}

	public void BuildStoriesCache(String storiesDirectoryPath)
	{
		var dir = new Directory();
		dir.Open(storiesDirectoryPath);
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
				BuildStoriesCache(storiesDirectoryPath + "/" + file);
			}
			else if (file.EndsWith(".ink.json"))
			{
				var storyPath = storiesDirectoryPath + "/" + file;
				Story story = LoadStoryFromFile(storyPath);
				LoadSaveOrReset(0, storyPath, story);
				stories.Add(storyPath, story);
			}
		}
		dir.ListDirEnd();
	}

	private Story LoadStoryFromFile(String input_path)
	{
		String text = System.IO.File.ReadAllText(input_path);
		return new Story(text);
	}

	public void LoadStory(String input_path)
	{
		Story mapValue;
		if (stories.TryGetValue(input_path, out mapValue))
		{
			_inkStory = mapValue;
		}
		else
		{
			_inkStory = LoadStoryFromFile(input_path);
			LoadSaveOrReset(0, input_path, _inkStory);
			stories.Add(input_path, _inkStory);
		}
	}

	public void Reset()
	{
		_inkStory.ResetState();
	}

	private String GetSaveFilePath(int slot, String storyPath)
	{
		return string.Format("user://saves/slot_{0}/", slot) + storyPath + ".sav";
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

	// Saves all stories from the stories dictionary. Each one will create its own file in the user's profile folder.
	public void SaveAll(int slot)
	{
		foreach (var pair in stories)
		{
			String path = pair.Key;
			Story story = pair.Value;
			string savedJson = story.state.ToJson();
			File saveFile = new File();
			saveFile.Open(GetSaveFilePath(slot, path), 2); // File.ModeFlags.WRITE
			saveFile.StoreString(savedJson);
			saveFile.Close();
			
			File slotCaptionFile = new File();
			slotCaptionFile.Open(GetSlotCaptionFilePath(slot), 2); // File.ModeFlags.WRITE
			slotCaptionFile.StoreString(DateTime.Now.ToString());
			slotCaptionFile.Close();
		}
	}

	private bool LoadSaveOrReset(int slot, String path, Story story)
	{
		File saveFile = new File();
		String saveFilePath = GetSaveFilePath(slot, path);
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
			String path = pair.Key;
			Story story = pair.Value;
			LoadSaveOrReset(slot, path, story);
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
