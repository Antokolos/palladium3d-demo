VAR relationship_female = 0
*	[I guess this room belongs to the god of war.]
	I guess this room belongs to the god of war.	# actor:player
	Yes, this is a statue of Ares, the god of war. Do we need to take all the statues?	# actor:female
	I don't know, but it's better to take whatever we can.	# actor:player
*	[Xenia, how do you feel?]
	~ relationship_female = relationship_female + 1
	Xenia, how do you feel?	# actor:player
	My head hurts a little. We got out right in time.	# actor:female