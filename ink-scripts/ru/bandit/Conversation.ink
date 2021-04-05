EXTERNAL is_actual(activatable_id)
EXTERNAL player_is_in_room(room_id)
EXTERNAL conversation_is_not_finished(conversation_name)
- (conversation)
Да?	# actor:bandit
+	{is_actual(30)} [Макс, есть мысли?]
	Макс, есть мысли?	# actor:player # voiceover:2570_maks_est_mysli.ogg
	Эти штуки со скульптурами вращаются, значит их надо выставить в правильную позицию. Вероятно тогда и кнопка с яблоком сработает. Вся эта система напоминает мне кодовый замок на чемодане. Обычно, когда часть механизма встаёт в нужное положение, раздаётся щелчок. Покрути-ка статуи ещё раз.	# actor:bandit # voiceover:33_shtuki_so_skulpturami.ogg	# finalizer
+	[Давай позже поговорим, нельзя отвлекаться.]
	Давай позже поговорим, нельзя отвлекаться.	# finalizer
-	-> conversation