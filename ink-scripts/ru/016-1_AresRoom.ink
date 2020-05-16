VAR relationship_female = 0
*	[Похоже, это комната бога войны.]
	Похоже, это комната бога войны.	# actor:player # voiceover:245_pohozhe_eto_komnata_boga_voiny.ogg
	Да, это статуэтка Ареса -- бога войны. А мы должны все статуэтки собирать?	# actor:female # voiceover:290_da_eto_statuetka_Aresa_boga.ogg
	Не знаю, но лучше взять все какие возможно.	# actor:player # voiceover:244_ne_znayu_no_luchshe_vzyat.ogg
*	[Ксения, как ты себя чувствуешь?]
	~ relationship_female = relationship_female + 1
	Ксения, как ты себя чувствуешь?	# actor:player # voiceover:243_Xenia_kak_ty_sebya.ogg
	Голова немного болит. Мы вовремя оттуда ушли.	# actor:female # voiceover:289_golova_nemnogo_bolit.ogg