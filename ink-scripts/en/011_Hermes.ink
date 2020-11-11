VAR relationship_female = 0
Andreas, aren't you going to criticize me?	# actor:female # voiceover:535_Andreas_aren't_you_going.ogg
Do you want me to?	# actor:player # voiceover:463_do_you_want_me_too.ogg
No, but it was my mistake grabbing the statue.	# actor:female # voiceover:536_no_but_it_was_my_mistake.ogg
* 	[А я ведь просил ничего не трогать!]
	А я ведь просил ничего не трогать! # actor:player # voiceover:.ogg
	-> hermes_continue
* 	[I would have taken it eventually anyway.]
	~ relationship_female = relationship_female + 1
	I would have taken it eventually anyway. But first I would study the room and everything inside.	# actor:player # voiceover:464_i_would_have_taken_it.ogg
	-> hermes_continue
=== hermes_continue ===
If you are done flirting with each other , maybe we should think what to do next? Are we taking another statue from the pedestal and activating another trap?	# actor:bandit # voiceover:18_done_flirting.ogg
We don't know for sure what is going to happen.	# actor:player # voiceover:465_we_don't_know_for_sure.ogg
We should just take the statue then.	# actor:bandit # voiceover:19_we_should_just_take.ogg
Xenia, can you tell us anything about this statue?	# actor:player # voiceover:466_Xenia_can_you_tell_us.ogg
According to its attributes, this should be Hermes, the god of trade. I could tell you a lot about him, but I'm not sure which legend could prove useful right now. If you're done looking around the room, let's try to take the statue.	# actor:female # voiceover:537_according_to_its_attributes.ogg
-> DONE