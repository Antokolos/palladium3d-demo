VAR relationship_female = 0
*	[Похоже, это комната бога войны.]
	Похоже, это комната бога войны.	# actor:player # voiceover:2549_pohozhe_eto_komnata.ogg
	Да, это статуэтка Ареса -- бога войны. А мы должны все статуэтки собирать?	# actor:female # voiceover:290_da_eto_statuetka_Aresa_boga.ogg
	Не знаю, но лучше взять все какие возможно.	# actor:player # voiceover:2551_ne_znayu_no_luchshe.ogg
*	[Ксения, как ты себя чувствуешь?]
	~ relationship_female = relationship_female + 1
	Ксения, как ты себя чувствуешь?	# actor:player # voiceover:2550_ksenya_kak_ty_sebya.ogg
	Голова немного болит. Мы вовремя оттуда ушли.	# actor:female # voiceover:289_golova_nemnogo_bolit.ogg