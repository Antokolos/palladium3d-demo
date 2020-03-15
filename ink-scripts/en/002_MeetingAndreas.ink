VAR party_female = true
Who's there? Why are you crouching? Wanted to pass me by, without even asking what I was doing here alone? What if I'm lost?	# actor:female
Are you lost?	# actor:player
No, but I could use some help. I got stuck on this island because I missed my ferry and the next one will come here the day after tomorrow in the evening. I had a little water with me, but it's so hot today, so I drank it already.	# actor:female
You came to a deserted island without supplies?	# actor:player
I wanted to go to Crete, but sometimes I become so absent-minded, worse than Paganel himself. So I disembarked on the wrong island, and when I realized my mistake, the ferry was already gone. And how did you get here?	# actor:female
I came on a boat.	# actor:player
You got the wrong island, too, or did you come here for a reason?	# actor:female
I study small Greek islands that were neglected by prominent archeologists, so there's still a chance to find ancient artifacts here.	# actor:player
What exactly are you looking for?	# actor:female
Anything I can come across.	# actor:player
It's easier to explore the island with some light gear, and you have a large backpack, which makes me think you have a certain goal. Do you have some specific information about this island? You can trust me; I won't tell anyone. There's no one here after all.	# actor:female
Exactly. Only you and I. Aren't you scared to be here with me alone?	# actor:player
No, you have kind eyes, and your face tells me you are a good person, even though you look serious. That's probably because you don't smile much. You need to smile more often.	# actor:female
You're doing it enough for both of us, so I don't have to. I can bring you to Crete if you want.	# actor:player
Really? Cool, I'd be very greatf…	# actor:female
*	[Go to the shore and wait for me by the boat.]
	Go to the shore and wait for me by the boat.	# actor:player
	~ party_female = false