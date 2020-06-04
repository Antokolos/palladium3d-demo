VAR relationship_female = 0
*	[I guess this room belongs to the god of war.]
	I guess this room belongs to the god of war.	# actor:player # voiceover:489_i_guess_his_room_belongs.ogg
	Yes, this is a statue of Ares, the god of war. Do we need to take all the statues?	# actor:female # voiceover:570_yes_this_is_a_statue_of_Ares.ogg
	I don't know, but it's better to take whatever we can.	# actor:player # voiceover:491_i_don't_know_but_it's_better.ogg
*	[Xenia, how do you feel?]
	~ relationship_female = relationship_female + 1
	Xenia, how do you feel?	# actor:player # voiceover:490_Xenia_how_do_you_feel.ogg
	My head hurts a little. We got out right in time.	# actor:female # voiceover:569_my_head_hurts_a_little.ogg