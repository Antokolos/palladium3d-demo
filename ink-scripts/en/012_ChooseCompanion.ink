VAR party_female = true
VAR party_bandit = true
Now do you see how dangerous this place is? Are you sure you still want to continue?	# actor:player # voiceover:467_now_do_you_see_how.ogg
I'll keep on going. But only alone.	# actor:bandit # voiceover:20_I'll_keep_on_going.ogg
Being alone out here is twice as dangerous.	# actor:player # voiceover:468_being_alone_out_here.ogg
Being with you two is three times more dangerous.	# actor:bandit # voiceover:21_three_times_more_dangerous.ogg
I get the hint. Go together if you want; I can go through the traps on my own just fine.	# actor:female # voiceover:545_i_get_the_hint.ogg
We need to all go together. I'm sure each of us will be extremely cautious from now on.	# actor:player # voiceover:2581_we_need_to_all_go.ogg
I'm confident you two would just keep solving riddles and telling old stories, but I have a different approach.	# actor:bandit # voiceover:22_solving_riddles_telling_stories.ogg
I'm sure we can come to an agreement.	# actor:player # voiceover:470_i'm_sure_we_can_come.ogg
When the trap is triggered, there will be no time to debate.	# actor:bandit # voiceover:23_when_the_trap_is_triggered.ogg
Apparently every room has a riddle. It seems likely given what we've seen so far. We can win by playing by the rules.	# actor:female # voiceover:546_apparently_every_room_has.ogg
I'm not going to dance to somebody's ancient pipe. I'm going to go my own way.	# actor:bandit # voiceover:24_dance_to_pipe.ogg
*	(companion_xenia) [Choose Xenia.]
	Xenia, let's go together. Max, come with us.	# actor:player # voiceover:471_Xenia_let's_go_together.ogg
	I've decided to go alone. When I find gold, I promise not to take all for myself; I'll leave something for you.	# actor:bandit # voiceover:25_decided_to_go_alone.ogg
	~ party_bandit = false
*	(companion_max) [Choose Max.]
	Max, I like your approach better, but I can't let Xenia go alone.	# actor:player # voiceover:472_Max_i_like_your_approach.ogg
	Andreas, go with Max if you want. You don't have to babysit me. I still need to look at Parthenon and Knossos.	# actor:female # voiceover:547_Andreas_go_with_Max.ogg
	Don't you want to know what secrets this maze is hiding? Oh — I bet you’re just going to pretend that you're leaving but will be following us instead.	# actor:player # voiceover:473_don't_you_want_to.ogg
	No, I'll just return when you leave. Hey! I’m just kidding! I'll just wait for the ferry and leave, I promise. But I have one condition. Andreas, promise to give me a call when you'll find this artifact of your dreams to tell me about it. Here is my number.	# actor:female # voiceover:548_no_i'll_just_return.ogg
	I'll give you a call, I promise.	# actor:player # voiceover:474_i'll_give_you_a_call.ogg
	Good luck to you both.	# actor:female # voiceover:549_good_luck_to_you_both.ogg
	~ party_female = false
* 	[Идти одному.]
	That is a difficult choice. I'll go alone, like I planned from the beginning.	# actor:player # voiceover:2096_that_is_a_difficult_choice.ogg
	Andreas, I'm the only specialist on ancient Greek language and mythology. 	# actor:female # voiceover:2168_Andreas_i'm_the_only.ogg
	Andreas, are you sure you can do this on your own?	# actor:bandit # voiceover:2269_Andreas_are_you_sure.ogg
	* * 	[Go with Xenia.]
		-> companion_xenia
	* * 	[Go with Max.]
		-> companion_max
	* * 	[Go alone.]
		That is a difficult choice. I'll go alone, like I planned from the beginning.	# actor:player # voiceover:2096_that_is_a_difficult_choice.ogg
		~ party_bandit = false
		~ party_female = false