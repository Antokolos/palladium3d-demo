VAR relationship_female = 0
VAR party_female = true
Привет.	# actor:player # voiceover:2446_privet.ogg
Фух, ты меня напугал.	# actor:female # voiceover:134_fuh_ty_menya_napugal.ogg
Всё в порядке? Ты не заблудилась?	# actor:player # voiceover:2447_vsyo_v_poryadke.ogg
Да, то есть нет. Я залюбовалась природой острова и опоздала на паром, а следующий только через два дня.	# actor:female # voiceover:135_da_to_est_net.ogg
Давно ты здесь?	# actor:player # voiceover:2448_davno_ty_zdes.ogg
Уже несколько часов.	# actor:female # voiceover:136_uzhe_neskolko_chasov.ogg
Ты туристка?	# actor:player # voiceover:2449_ty_turistka.ogg
Ага, я приехала из…	# actor:female # voiceover:137_aga_ya_priehala_iz.ogg
Почему не позвонила в гостиницу?	# actor:player # voiceover:2450_pochemu_ne.ogg
Здесь сети нет. А как тебя зовут?	# actor:female # voiceover:138_zdes_seti_net.ogg
Андреас.	# actor:player # voiceover:2451_Andreas.ogg
А меня Ксения. А ты случайно не археолог?	# actor:female # voiceover:139_a_menya_Xenia.ogg
...	# actor:player # voiceover:empty.ogg
Удивлён как я догадалась? У тебя рюкзак, но гор здесь нет значит не альпинист. И насколько мне известно, лишь крупнейшие греческие острова тщательно исследовались, а к таким мелким, как этот, учёные почему-то проявили мало интереса. Поэтому мне кажется, что здесь ещё возможны археологические находки. Ты рассуждал так же?	# actor:female # voiceover:140_udivlen_kak_ya_dogadalas.ogg
Возможно. А что ты так увлечённо читала?	# actor:player # voiceover:2452_vozmozhno_a.ogg
Это просто блокнот, я набросала список греческих достопримечательностей, которые хочу посмотреть.	# actor:female # voiceover:141_eto_prosto_bloknot.ogg
И этот пустынный остров значится под номером один?	# actor:player # voiceover:2453_i_etot_pustynny_ostrov.ogg
А ты проницательный! Вообще-то я по ошибке оказалась на этом острове. Моей целью был Кносский дворец, но я иногда бываю такой рассеянной, прямо как Паганель, вот и высадилась не на том острове. Конечно я быстро поняла свою ошибку, но решила почему бы не прогуляться раз уж я здесь. Ну, а дальше ты знаешь, паром ушёл.	# actor:female # voiceover:142_a_ty_pronitsatelny.ogg
Почему выбрала Грецию?	# actor:player # voiceover:2454_pochemu_vybrala.ogg
Я с детства увлечена Грецией и всем что с ней связано. Вот наконец-то приехала в эту страну и мне здесь очень нравится. Андреас, а можно мне с тобой? Я не помешаю, а если и вправду удастся что-то обнаружить: ну там посуду какую или украшения вся слава достанется тебе одному.	# actor:female # voiceover:143_ya_s_detstva_uvlechena.ogg
Нет, это исключено.	# actor:player # voiceover:2455_net_eto_isklucheno.ogg
Что? Мне нельзя с тобой или тебе не нужна слава?	# actor:female # voiceover:144_cho_mne_melzya_s_toboy.ogg
Тебе нельзя идти со мной.	# actor:player # voiceover:2456_tebe_nelzya.ogg
Почему? Ты хочешь чтобы я два дня просидела на этом пне? И ещё две ночи.	# actor:female # voiceover:145_pochemu_ty_hochesh.ogg
Так бы и было если бы я не появился.	# actor:player # voiceover:2457_tak_by_i_bylo.ogg
Но ведь ты появился! А я упустила паром. Это знак! Мы должны идти вместе.	# actor:female # voiceover:146_no_ved_ty_poyavilsya.ogg
Там куда я направляюсь очень опасно. Я не имею права и не хочу подвергать риску никого кроме себя. Иди на берег, там стоит моя лодка. Я скоро приду и отвезу тебя на материк.	# actor:player # voiceover:2458_tam_kuda_ya.ogg
Понятно, спасибо за предупреждение, но теперь я не могу отпустить тебя одного в опасное путешествие. Вдвоём ведь лучше! В трудной ситуации напарник выручит тебя.	# actor:female # voiceover:147_ponyatno_spasibo_za_preduprezhdenie.ogg
*	[Взять Ксению с собой.]
	~ relationship_female = relationship_female + 1
	Ладно. Но ты должна во всём меня слушаться.	# actor:player # voiceover:2459_ladno_no_ty.ogg
	Здорово! Спасибо, что согласился, ты не пожалеешь.	# actor:female # voiceover:148_zdorovo_spasibo.ogg
	И поменьше болтай.	# actor:player # voiceover:2460_i_pomenshe_boltay.ogg
	Ага, я буду нема как рыба, как шпион в тылу врага, как… Ладно, не смотри так, я всё поняла. А у тебя очень проницательный взгляд.	# actor:female # voiceover:149_aga_budu_nema_kak_ryba.ogg
*	[Не брать Ксению с собой, отвезти на материк.]
	Ты не поняла. Ты можешь погибнуть.	# actor:player # voiceover:2467_ty_ne_ponyala.ogg
	Но ты ведь тоже рискуешь!	# actor:female # voiceover:155_no_ty_ved_tozhe.ogg
	Я взрослый мужчина и сам решаю что мне делать.	# actor:player # voiceover:2468_ya_vzrosly_muzhchina.ogg
	Так и я не ребёнок и тоже могу поступать как считаю нуж…	# actor:female # voiceover:156_tak_i_ya_ne_rebenok.ogg
	Хватит. Спорить бессмысленно. Иди на берег и жди меня там.	# actor:player # voiceover:2469_hvatit_sporit_bessmyslenno.ogg
	Ладно, я пойду. Угоню твою лодку и затеряюсь в море!	# actor:female # voiceover:157_ladno_ya_poydu.ogg
	~ party_female = false
	Чёрт знает что.	# actor:player # voiceover:2470_chort_znaet_chto.ogg