- (conversation)
* 	[Do not touch anything here. And keep up with me.]
    Do not touch anything here. And keep up with me. # actor:player
	Okay, I’ll try. But here everything is so interesting. Probably, these walls were built by some ancient people. # actor:female
	* * [Yes. But I am not here to study ancient architecture.]
	    Yes. But I am not here to study ancient architecture. # actor:player
		But why are you here then? # actor:female
		* * * 	[I have to find something.]
		        I have to find something. # actor:player
				How interesting! And what is it? # actor:female
				* * * * 	[I'll tell you later. Now we need to be very careful.]
				            I'll tell you later. Now we need to be very careful. # actor:player
							It is difficult to be careful when you are hungry. # actor:female
* 	[Be careful, the steps are very old.]
    Be careful, the steps are very old. # actor:player
	Okay. # actor:female
* 	[Are you afraid of rats?]
    Are you afraid of rats? # actor:player
	No, and I'm not afraid of insects either. And you? # actor:female
	* * [Of course not.]
	    Of course not. # actor:player
		Are there any rats here? # actor:female
		* * *	[Probably so.]
		        Probably so. # actor:player
* 	[Well, I agree, let's push the chest.]
    Well, I agree, let's push the chest.
	Okay.
+	[Let's talk later, we should not be distracted.]
    Let's talk later, we should not be distracted. # actor:player # finalizer
-	-> conversation