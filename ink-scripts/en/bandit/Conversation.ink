VAR apata_trap_stage = 0
VAR erida_trap_stage = 0
- (conversation)
Yes?	# actor:bandit
+	{erida_trap_stage > 1} [Max, any ideas?]
	Max, any ideas?	# actor:player
	These things with statues can be rotated, so we need to put them in their proper positions. Then the apple button should work. This system reminds me of a code lock on a suitcase. Usually when a part of a mechanism gets to its proper place there will be a clicking sound. Rotate that statue once again.	# actor:bandit	# finalizer
+	[Let's talk later, we should not be distracted.]
	Let's talk later, we should not be distracted.	# finalizer
-	-> conversation