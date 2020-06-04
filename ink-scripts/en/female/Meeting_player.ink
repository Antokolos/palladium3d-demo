VAR relationship_female = 0
VAR party_female = true
Hello.	# actor:player # voiceover:307_hello.ogg
Oh! You scared me.	# actor:female # voiceover:352_oh_you_scared_me.ogg
Is everything alright? Are you lost?	# actor:player # voiceover:308_is_everything_alright.ogg
Yes — well, I mean no. I was admiring the beauty of this place and missed the ferry, and the next one doesn’t come for two days.	# actor:female # voiceover:353_yes_well_i_mean_no.ogg
How long have you been here?	# actor:player # voiceover:309_how_long_have_you.ogg
A few hours.	# actor:female # voiceover:354_a_few_hours.ogg
Are you a tourist?	# actor:player # voiceover:310_are_you_a_tourist.ogg
Yep, I came from…	# actor:female # voiceover:355_yep_i_came_from.ogg
Can't you just phone your hotel?	# actor:player # voiceover:311_can't_you_just_phone.ogg
My cell phone provider has no coverage here. What is your name?	# actor:female # voiceover:356_my_cell_phone_provider.ogg
Andreas.	# actor:player # voiceover:312_Andreas.ogg
And I'm Xenia. Are you by any chance an archeologist?	# actor:female # voiceover:357_1_and_i'm_Xenia.ogg
...	# actor:player
You want to know how I guessed? You have a large backpack, but there are no mountains here, so you're not a mountain climber. And as far as I know, only the largest Greek islands have been thoroughly explored by scientists, unlike small islands like this one. That's why I think it's a good place for archeological finds. Did you have the same thoughts?	# actor:female # voiceover:357_you_want_to_know_how.ogg
Maybe. What were you reading?	# actor:player # voiceover:313_maybe_what_were_you.ogg
That was just my notes on the Greek sights I wanted to see.	# actor:female # voiceover:358_that_was_just_my_notes.ogg
So this deserted island is number one on your list?	# actor:player # voiceover:314_so_this_deserted_island.ogg
You are a clever one indeed! Actually, I got here by mistake. I was hoping to look at Knossos, but I get so absent-minded sometimes, just like Paganel, so I disembarked on the wrong island. Of course I realized my mistake, but I decided to explore a little since I'm here. You know the rest; now the ferry is gone.	# actor:female # voiceover:359_you_are_a_clever_one.ogg
Why did you pick Greece?	# actor:player # voiceover:315_why_did_you_pick.ogg
I have been fondly dreaming of Greece since my childhood. Now that I’ve finally come here, I like everything so far. We can explore together — I won't be a burden. And if we actually find something, like vessels or adornments, you will get all the glory.	# actor:female # voiceover:360_i_have_been_fondly.ogg
No, this is out of the question.	# actor:player # voiceover:316_no_this_is_out_of_the.ogg
What do you mean? That I can't go with you or that you don't need fame?	# actor:female # voiceover:361_what_do_you_mean.ogg
You can't go with me.	# actor:player # voiceover:317_you_can't_go_with_me.ogg
Why not? You want me to sit on this stump for two days?	# actor:female # voiceover:362_why_not_you_want_me_to.ogg
You would have if I hadn't shown up.	# actor:player # voiceover:318_you_would_have_if_i.ogg
But you did show up! And I missed my ferry. That's a sign! We must go together.	# actor:female # voiceover:363_but_you_did_show_up.ogg
The place I'm going is very dangerous. I wouldn't want to put somebody else's life at risk. Go to the shore; my boat is over there. Soon I will come and bring you back to the mainland.	# actor:player # voiceover:319_the_place_i'm_going_is_probably.ogg
I see; thanks for the warning, but now I can't let you go alone. It's safer to have a companion who can give you a hand in dire straits.	# actor:female # voiceover:364_i_see_thanks_for_the_warning.ogg
*	[Accept the offer.]
	~ relationship_female = relationship_female + 1
	Fine. But you need to do as I say.	# actor:player # voiceover:320_fine_but_you_need_to_do.ogg
	Great! Thanks, you won't regret it.	# actor:female # voiceover:365_great_thanks_you_wont.ogg
	And stop being a chatterbox.	# actor:player # voiceover:321_and_stop_being_a.ogg
	Ok, I'll be silent as the grave, as mute as a fish, like… Ok, don't look at me like that, I get it. You have a very sharp gaze.	# actor:female # voiceover:366_ok_i'll_be_silent.ogg
*	[Decline the offer.]
	You don't understand. You may die.	# actor:player # voiceover:328_you_don't_understand.ogg
	But it's dangerous for you too.	# actor:female # voiceover:371_but_it's_dangerous_for_you_too.ogg
	I'm a grown man, and I can decide for myself what to do.	# actor:player # voiceover:329_i'm_a_grown_man.ogg
	I'm not a child either, and can do what I wan…	# actor:female # voiceover:372_i'm_not_a_child_either.ogg
	Enough arguing. Go to the shore and wait for me there.	# actor:player # voiceover:330_enough_arguing.ogg
	Fine, I'm going. I will drive away with your boat and vanish at sea!	# actor:female # voiceover:373_fine_i'm_going.ogg
	~ party_female = false
	What a nuisance!	# actor:player # voiceover:331_what_a_nuisance.ogg