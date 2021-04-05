EXTERNAL is_paused(activatable_id)
EXTERNAL is_actual(activatable_id)
EXTERNAL player_is_in_room(room_id)
- (conversation)
Yes?	# actor:female
+	{is_paused(20)} [Xenia, what is written here?]
	Xenia, what is written here?	# actor:player # voiceover:456_Xenia_what_is_written.ogg
	The inscription says: "Reveal the deception and restore the truth". The first sign says "Theater," the second "Astronomy," and the third is "History".	# actor:female # voiceover:527_the_inscription_says_reveal.ogg
	+ +	[Do you know something about these statues?]
		Do you know something about these statues?	# actor:player # voiceover:458_do_you_know_something.ogg
		I think these are statues of muses. There are twelve muses, but there's only three of them here. The patroness of theater — Melpomene, astronomy — Urania, and history — Clio. I don't remember exactly how they are usually depicted, but I think they are standing on the wrong pedestals here.	# actor:female # voiceover:528_i_think_these_are_statues.ogg	# finalizer
	+ +	[Got it.]
		Got it.	# actor:player # voiceover:457_got_it.ogg # finalizer
+	{is_actual(30)} [Xenia, is there a myth about Eris?]
	Xenia, is there a myth about Eris?	# actor:player # voiceover:487_Xenia_is_there_a_myth.ogg
	Eris is a goddess of strife. She was the one to stealthily place an apple inscribed with "callisti", which means "for the most beautiful", before Hera, Aphrodite, and Athena. The goddesses started to dispute to whom this apple was addressed.	# actor:female # voiceover:567_Eris_is_a_goddess_of_strife.ogg
	Aphrodite is the goddess of beauty, Athena is the goddess of fair war, and Hera is the supreme goddess. # actor:female # voiceover:2345_Aphrodite_is_the_goddess_of.ogg	# finalizer
+	{player_is_in_room(70)} [This dry branch was left here for a reason. This is a clue.]
	This dry branch was left here for a reason. This is a clue. # actor:player # voiceover:1496_this_dry_branch.ogg
	It looks like a dry cypress branch. By the way, this is associated with Hebe. # actor:female # voiceover:1525_it_looks_like_a_dry.ogg	# finalizer
+	{player_is_in_room(80)} [This is a peacock. Is that one of Hera's symbols?]
	This is a peacock. Is that one of Hera's symbols? # actor:player # voiceover:1725_this_is_a_peacock.ogg
	Yes. # actor:female # voiceover:1795_yes.ogg
	Is there a legend? # actor:player # voiceover:1726_is_there_a_legend.ogg
	Of course. After Argus' death his eyes scattered over the ground. Cupids gathered and brought them to Hera. And the goddess put them on the peacock's tail. # actor:female # voiceover:1796_of_course_after.ogg	# finalizer
+	{player_is_in_room(90)} [Xenia, what are these inscriptions? Are they the names of the gods?]
	Xenia, what are these inscriptions? Are they the names of the gods? # actor:player # voiceover:1633_Xenia_what_are_these_inscriptions.ogg
	Yes. The first sector says Apollo, the second Venus, and the third Mars. And I have a clue how the names are related to the planets. # actor:female # voiceover:1709_yes_the_first_sector.ogg
	I also have an idea. # actor:player # voiceover:1634_i_also_have_an_idea.ogg
	Let's hear it. # actor:female # voiceover:1710_lets_hear_it.ogg
	I remember that Ares was the god of war for the Greeks, but in Roman mythology it's Mars. The Roman goddess of love was Venus. # actor:player # voiceover:1635_i_remember_that_Ares.ogg	# finalizer
+	{player_is_in_room(110)} [Xenia, what is written here?]
	Xenia, what is written here? # actor:player # voiceover:1322_Xenia_what_is_written.ogg
	"Zeus's children will show the way." # actor:female # voiceover:1969_Zeus's_children.ogg
	+ +	[I see, another riddle.]
		I see, another riddle. # actor:player # voiceover:1943_i_see_another.ogg	# finalizer
	+ +	[Do you know who his children are?]
		Do you know who his children are? # actor:player # voiceover:1944_do_you_know_who.ogg
		Zeus had a lot of children: Ares, Hermes, Aphrodite, Hebe, Artemis, Apollo, and that is not all of them. # actor:female # voiceover:1970_Zeus_had_a_lot.ogg	# finalizer
+	[Let's talk later, we should not be distracted.]
	Let's talk later, we should not be distracted.	# finalizer
-	-> conversation