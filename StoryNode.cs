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
				story.ResetState();
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
			Reset();
		}
	}

	public void Reset()
	{
		_inkStory.ResetState();
	}

	public bool CanContinue()
	{
		return _inkStory.canContinue;
	}

	public String Continue()
	{
		return _inkStory.Continue();
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
