VAR relationship_female = 0
VAR party_female = true
Hello.	# actor:player
Oh! You scared me.	# actor:female
Is everything alright? Are you lost?	# actor:player
Yes — well, I mean no. I was admiring the beauty of this place and missed the ferry, and the next one doesn’t come for two days.	# actor:female
How long have you been here?	# actor:player
A few hours.	# actor:female
Are you a tourist?	# actor:player
Yep, I came from…	# actor:female
Can't you just phone your hotel?	# actor:player
My cell phone provider has no coverage here. What is your name?	# actor:female
Andreas.	# actor:player
And I'm Xenia. Are you by any chance an archeologist?	# actor:female
...	# actor:player
You want to know how I guessed? You have a large backpack, but there are no mountains here, so you're not a mountain climber. And as far as I know, only the largest Greek islands have been thoroughly explored by scientists, unlike small islands like this one. That's why I think it's a good place for archeological finds. Did you have the same thoughts?	# actor:female
Maybe. What were you reading?	# actor:player
That was just my notes on the Greek sights I wanted to see.	# actor:female
So this deserted island is number one on your list?	# actor:player
You are a clever one indeed! Actually, I got here by mistake. I was hoping to look at Knossos, but I get so absent-minded sometimes, just like Paganel, so I disembarked on the wrong island. Of course I realized my mistake, but I decided to explore a little since I'm here. You know the rest; now the ferry is gone.	# actor:female
Why did you pick Greece?	# actor:player
I have been fondly dreaming of Greece since my childhood. Now that I’ve finally come here, I like everything so far. We can explore together — I won't be a burden. And if we actually find something, like vessels or adornments, you will get all the glory.	# actor:female
No, this is out of the question.	# actor:player
What do you mean? That I can't go with you or that you don't need fame?	# actor:female
You can't go with me.	# actor:player
Why not? You want me to sit on this stump for two days?	# actor:female
You would have if I hadn't shown up.	# actor:player
But you did show up! And I missed my ferry. That's a sign! We must go together.	# actor:female
The place I'm going is very dangerous. I wouldn't want to put somebody else's life at risk. Go to the shore; my boat is over there. Soon I will come and bring you back to the mainland.	# actor:player
I see; thanks for the warning, but now I can't let you go alone. It's safer to have a companion who can give you a hand in dire straits.	# actor:female
*	[Accept the offer.]
	~ relationship_female = relationship_female + 1
	Fine. But you need to do as I say.	# actor:player
	Great! Thanks, you won't regret it.	# actor:female
	And stop being a chatterbox.	# actor:player
	Ok, I'll be silent as the grave, as mute as a fish, like… Ok, don't look at me like that, I get it. You have a very sharp gaze.	# actor:female
*	[Decline the offer.]
	You don't understand. You may die.	# actor:player
	But it's dangerous for you too.	# actor:female
	I'm a grown man, and I can decide for myself what to do.	# actor:player
	I'm not a child either, and can do what I wan…	# actor:female
	Enough arguing. Go to the shore and wait for me there.	# actor:player
	Fine, I'm going. I will drive away with your boat and vanish at sea!	# actor:female
	~ party_female = false
	What a nuisance!	# actor:player