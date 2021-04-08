EXTERNAL is_actual(activatable_id)
EXTERNAL player_is_in_room(room_id)
EXTERNAL conversation_is_not_finished(conversation_name)
- (conversation)
Yes?	# actor:bandit
+	{is_actual(30)} [Max, any ideas?]
	Max, any ideas?	# actor:player # voiceover:511_Max_any_ideas.ogg
	These things with statues can be rotated, so we need to put them in their proper positions. Then the apple button should work. This system reminds me of a code lock on a suitcase. Usually when a part of a mechanism gets to its proper place there will be a clicking sound. Rotate that statue once again.	# actor:bandit # voiceover:33_things_with_statues_can_be_rotated.ogg	# finalizer
+	[Let's talk later, we should not be distracted.]
	Let's talk later, we should not be distracted.	# finalizer
-	-> conversation