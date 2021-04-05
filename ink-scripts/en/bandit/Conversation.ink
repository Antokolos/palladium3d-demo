EXTERNAL is_actual(activatable_id)
EXTERNAL player_is_in_room(room_id)
EXTERNAL conversation_is_not_finished(conversation_name)
- (conversation)
Yes?	# actor:bandit
+	{is_actual(30)} [Max, any ideas?]
	Max, any ideas?	# actor:player # voiceover:511_Max_any_ideas.ogg
	These things with statues can be rotated, so we need to put them in their proper positions. Then the apple button should work. This system reminds me of a code lock on a suitcase. Usually when a part of a mechanism gets to its proper place there will be a clicking sound. Rotate that statue once again.	# actor:bandit # voiceover:33_things_with_statues_can_be_rotated.ogg	# finalizer
+	{player_is_in_room(70)} [This dry branch was left here for a reason. This is a clue.]
	This dry branch was left here for a reason. This is a clue. # actor:player # voiceover:1496_this_dry_branch.ogg
	Andreas, you know our approach. When the trap gets triggered, we'll decide what to do with it. # actor:bandit # voiceover:1215_Andreas_you_know_our.ogg	# finalizer
*	{player_is_in_room(80) && conversation_is_not_finished("107_Statue_on_the_other_side")} [It seems that the statue is on the other side, but how can we reach it?]
	It seems that the statue is on the other side, but how can we reach it? # actor:player # voiceover:1737_it_seems_that.ogg
	Let's think logically. I can't see the bottom, but maybe it's not that deep. # actor:bandit # voiceover:1303_lets_think_logically.ogg
	And how do we find out for sure? # actor:player # voiceover:1738_and_how_do_we.ogg
	I brought one device with me, just in case, although I doubted it was going to be useful. It’s a pocket echo-sounder. # actor:bandit # voiceover:1304_i_brought_one_device.ogg
	Its effective range is around 10 meters. # actor:bandit # voiceover:1306_but_keep_in_mind.ogg
	That's great, Max! # actor:player # voiceover:1739_thats_great_max.ogg
	I scanned the precipice. There is a path, but it looks like it consists of separate segments. So we need to walk slowly and very carefully. # actor:bandit # voiceover:1307_i_scanned_the_prescipice.ogg	# finalizer:10
*	{player_is_in_room(90) && conversation_is_not_finished("082_Sun_clue")} [The Sun is obviously a clue.]
	The Sun is obviously a clue. # actor:player # voiceover:1676_the_sun_is_obviously_a.ogg
	The first thing that comes to mind is to direct a beam of light onto the stone slab with a drawing. # actor:bandit # voiceover:1279_the_first_thing_that.ogg
	Yeah, but I already lit it with my flashlight and nothing happened. # actor:player # voiceover:1677_yeah_but_i_already.ogg
	Maybe it requires a beam of sunlight. # actor:bandit # voiceover:1280_maybe_it_requires.ogg
	But there's no sunlight in here. # actor:player # voiceover:1678_but_there_is_no.ogg
	Do you know the difference between sunlight and electrical light? # actor:bandit # voiceover:1281_do_you_know_the.ogg
	No. # actor:player # voiceover:1679_no.ogg
	The presence of ultraviolet radiation. Try to use my ultraviolet flashlight. # actor:bandit # voiceover:1282_the_presence_of.ogg	# finalizer:20
+	{player_is_in_room(110)} [I think Palladium is hidden in this hall.]
	I think Palladium is hidden in this hall. # actor:player # voiceover:2332_i_think_palladium_.ogg
	Then let's look for it. # actor:bandit # voiceover:2252_then_lets_look.ogg
	I have no ideas. There's an inscription on the wall, an inlay, and a small chest. I'm sure they have all the clues we need, but I can't understand their meaning. Max, can we break open the small chest? # actor:player # voiceover:2025_i_have_no_ideas.ogg
	No, Andreas, the chest looks very solid. Chin up, mate! We'll come back next time with some ancient Greece expert. Then we’ll find your Palladium! # actor:bandit # voiceover:2253_no_andreas_the_chest_looks.ogg
	Yeah, my Palladium. # actor:player # voiceover:2026_yeah_my_Palladium.ogg	# finalizer
+	[Let's talk later, we should not be distracted.]
	Let's talk later, we should not be distracted.	# finalizer
-	-> conversation