VAR apata_chest_rigid = 0
Andreas, this is Apate, a goddess…	# actor:female
Don't touch it! Everybody out!	# actor:player
The ceiling is moving.	# actor:female
The trap works after all.	# actor:bandit
Andreas, I'm sorry…	# actor:female
Not now. Remember the sign: "Each riddle has a solution"? It means there's a way out. We just need to find it. We could use something in this room.	# actor:player
Andreas, I think it might be this casket of Pandora. There's a legend…	# actor:female
Yeah, now’s a great time for stories! Andreas, I noticed something on the ceiling, look.	# actor:bandit
*	[Listen to Xenia.]
	Xenia, what legend?	# actor:player
	When Pandora opened the casket, she released all sorts of evil spirits and misfortunes. Apate was one of them, a goddess of deception. But hope was left in the bottom of the casket, unnoticed although it had always been there.	# actor:female
	Apparently, Apate symbolizes all the misfortunes in Pandora's casket. But among the misfortunes and trials, there's always hope.	# actor:player
*	[Listen to Max.]
	Max, what have you noticed?	# actor:player
	On the ceiling, right above the casket, there are no spikes! If we remove the casket, we can stand where it stands now.	# actor:bandit
	What if it doesn't work? We need to solve the riddle and find the exit.	# actor:female
	Removing the casket is quicker. Andreas, give me a hand; the casket is heavy.	# actor:bandit
	Ok. On the count three we push.	# actor:player
	~ apata_chest_rigid = 1