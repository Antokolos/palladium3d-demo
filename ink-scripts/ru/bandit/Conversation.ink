VAR apata_trap_stage = 0
VAR erida_trap_stage = 0
- (conversation)
Да?	# actor:bandit
+	{erida_trap_stage > 1} [Макс, есть мысли?]
	Макс, есть мысли?	# actor:player
	Эти штуки со скульптурами вращаются, значит их надо выставить в правильную позицию. Вероятно тогда и кнопка с яблоком сработает. Вся эта система напоминает мне кодовый замок на чемодане. Обычно, когда часть механизма встаёт в нужное положение, раздаётся щелчок. Покрути-ка статуи ещё раз.	# actor:bandit	# finalizer
+	[Давай позже поговорим, нельзя отвлекаться.]
	Давай позже поговорим, нельзя отвлекаться.	# finalizer
-	-> conversation