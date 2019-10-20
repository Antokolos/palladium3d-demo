using Godot;
using System;
using System.Collections.Generic;
using Ink.Runtime;

public class PalladiumStory
{
	private Story _inkstory;
	
	public Story InkStory
	{
		get { return _inkstory; }
		set { _inkstory = value; }
	}
	
	private Dictionary<String, String> _storylog;
	
	/// Story log by locale
	public Dictionary<String, String> StoryLog
	{
		get { return _storylog; }
	}
	
	private bool _chatdriven;
	
	/// Story choices can be chosen in chat
	public bool ChatDriven
	{
		get { return _chatdriven; }
		set { _chatdriven = value; }
	}
	
	public PalladiumStory(Story inkstory, bool chatdriven)
	{
		_inkstory = inkstory;
		_storylog = new Dictionary<String, String>();
		_chatdriven = chatdriven;
	}
}