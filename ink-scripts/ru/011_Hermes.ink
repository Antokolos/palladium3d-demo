VAR relationship_female = 0
Андреас, почему ты меня не ругаешь?	# actor:female # voiceover:222_Andreas_pochemu_ty_menya.ogg
Ты этого хочешь?	# actor:player # voiceover:122_ty_etogo_hochesh.ogg
Нет, но я же виновата, схватила статуэтку.	# actor:female # voiceover:223_net_no_ya_zhe_vinovata.ogg
* 	[А я ведь просил ничего не трогать!]
	~ relationship_female = relationship_female - 1
	А я ведь просил ничего не трогать! # actor:player # voiceover:1133_a_ya_ved_prosil.ogg
	-> hermes_continue
* 	[Эту статуэтку всё равно пришлось бы взять.]
	~ relationship_female = relationship_female + 1
	Эту статуэтку всё равно пришлось бы взять. Только сначала я бы тщательно осмотрел комнату. # actor:player # voiceover:1134_etu_statuetku_vsyo_ravno.ogg
	-> hermes_continue
=== hermes_continue ===
Если вы закончили любезничать, может подумаем что делать дальше? Опять снимем статуэтку с пьедестала и активируем новую ловушку?	# actor:bandit # voiceover:18_esly_vy_zakonchily_lyubeznichat.ogg
Что произойдёт точно не известно.	# actor:player # voiceover:124_chto_proizoidot_tochno_ne_izvestno.ogg
Тогда надо просто взять статуэтку.	# actor:bandit # voiceover:19_nado_prosto_vzyat_statuetku.ogg
Ксения, ты можешь что-то рассказать о статуэтке?	# actor:player # voiceover:125_Xenia_ty_mozhesh_chto_to_rasskazat.ogg
Судя по атрибутам, это Гермес, бог торговли. О нём можно долго рассказывать, но непонятно какая конкретно легенда о Гермесе может быть полезна сейчас. Если ты осмотрел комнату и все предметы, попробуй взять статуэтку.	# actor:female # voiceover:224_sudya_po_atributam.ogg
-> DONE