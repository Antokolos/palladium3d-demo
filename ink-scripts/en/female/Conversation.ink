VAR apata_trap_stage = 0
VAR erida_trap_stage = 0
- (conversation)
Yes?	# actor:female
+	{apata_trap_stage > 2} [Xenia, what is written here?]
	Xenia, what is written here?	# actor:player
	The inscription says: "Reveal the deception and restore the truth". The first sign says "Theater," the second "Astronomy," and the third is "History".	# actor:female
	+ +	[Do you know something about these statues?]
		Do you know something about these statues?	# actor:player
		I think these are statues of muses. There are twelve muses, but there's only three of them here. The patroness of theater — Melpomene, astronomy — Urania, and history — Clio. I don't remember exactly how they are usually depicted, but I think they are standing on the wrong pedestals here.	# actor:female	# finalizer
	+ +	[Got it.]
		Got it.	# actor:player # finalizer
+	{erida_trap_stage > 1} [Xenia, is there a myth about Eris?]
	Xenia, is there a myth about Eris?	# actor:player
	Eris is a goddess of strife. She was the one to stealthily place an apple inscribed with "callisti", which means "for the most beautiful", before Hera, the supreme goddess, Aphrodite, the goddess of the beauty, and Athena, the goddess of the fair war. The goddesses started to dispute to whom this apple was addressed.	# actor:female	# finalizer
+	[Let's talk later, we should not be distracted.]
	Let's talk later, we should not be distracted.	# finalizer
-	-> conversation