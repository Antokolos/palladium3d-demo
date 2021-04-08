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
+	[Let's talk later, we should not be distracted.]
	Let's talk later, we should not be distracted.	# finalizer
-	-> conversation