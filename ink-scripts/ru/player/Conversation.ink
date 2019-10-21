VAR relationship_female = 0
VAR apata_chest_rigid = 0
- (conversation)
* 	[Ничего здесь не трогай. И не отставай.]
    Ничего здесь не трогай. И не отставай. # actor:player # voiceover:nichego_zdes_ne_trogai.ogg
	Ладно, я постараюсь. Но здесь всё такое интересное. Вероятно, эти стены возведены каким-то древним народом. # actor:female # voiceover:ladno_ya_postarayus.ogg
	* * [Да. Но я здесь не за тем, чтобы изучать старинную архитектуру.]
	    Да. Но я здесь не за тем, чтобы изучать старинную архитектуру. # actor:player # voiceover:da_no_ya_zdes_ne_zatem.ogg
		А зачем? # actor:female # voiceover:a_zachem.ogg
		* * * 	[Я должен кое-что отыскать.]
		        Я должен кое-что отыскать. # actor:player # voiceover:ya_dolzhen_koe_chto.ogg
				Как интересно! А что? # actor:female # voiceover:kak_interesno_a_chto.ogg
				* * * * 	[Потом расскажу. Сейчас нужно быть очень внимательным.]
				            Потом расскажу. Сейчас нужно быть очень внимательным. # actor:player # voiceover:potom_rasskazhu.ogg
							Сложно быть внимательной на голодный желудок. # actor:female # voiceover:slozhno_byt_vnimatelnoy.ogg
* 	[Будь осторожна, ступеньки очень старые.]
	~ relationship_female = relationship_female + 1
    Будь осторожна, ступеньки очень старые. # actor:player # voiceover:bud_ostotozhna.ogg
	Хорошо. # actor:female # voiceover:khorosho.ogg
* 	[Ты боишься крыс?]
    Ты боишься крыс? # actor:player # voiceover:ty_boishsya_krys.ogg
	Нет и насекомых тоже не боюсь. А ты? # actor:female # voiceover:net_i_nasekomykh.ogg
	* * [Конечно нет.]
	    Конечно нет. # actor:player # voiceover:konechno_net.ogg
		А здесь есть крысы? # actor:female # voiceover:a_zdes_est_krysy.ogg
		* * *	[Это вероятно.]
		        Это вероятно. # actor:player # voiceover:eto_veroyatno.ogg
* 	[Я согласен, помоги толкать сундук.]
	~ apata_chest_rigid = 1
    Я согласен, помоги толкать сундук.
	Хорошо.
+	[Давай позже поговорим, нельзя отвлекаться.]
    Давай позже поговорим, нельзя отвлекаться. # actor:player # voiceover:davay_pozhe_pogovorim.ogg # finalizer
-	-> conversation