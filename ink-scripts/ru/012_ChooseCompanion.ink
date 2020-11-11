VAR party_female = true
VAR party_bandit = true
Вы поняли, насколько здесь опасно? Уверены, что стоит продолжать?	# actor:player # voiceover:126_vy_ponaly_na_skolko_tut.ogg
Я пойду дальше. Но только один.	# actor:bandit # voiceover:20_ya_poydu_dalshe.ogg
Одному здесь вдвойне опасней.	# actor:player # voiceover:127_odnomu_zdes_vdvoyne.ogg
А с вами втройне опасней.	# actor:bandit # voiceover:21_vtroyne_opasney.ogg
Понятно на кого намёк. Идите вместе, а я сама справлюсь. Уверена что моих знаний хватит чтобы пройти ловушки.	# actor:female # voiceover:225_ponyatno_na_kogo_namyok.ogg
Надо идти всем вместе. Уверен, что впредь каждый из нас будет максимально осторожен.	# actor:player # voiceover:128_nado_idti_vsem_vmeste.ogg
Вы скорее всего захотите рассказывать легенды, разгадывать загадки, а у меня другой подход.	# actor:bandit # voiceover:22_rasskazyvat_legendy.ogg
Думаю мы сможем договориться.	# actor:player # voiceover:129_dumayu_my_smozhem.ogg
Когда ловушка сработает, времени на болтовню не будет.	# actor:bandit # voiceover:23_kogda_lovushka_srabotaet.ogg
Очевидно, что в каждой комнате есть загадка. Скорее всего это общий принцип. Зная правила, сможем выиграть.	# actor:female # voiceover:226_ochevidno_v_kazhdoy_komnate.ogg
Не хочу плясать под чью-то древнюю дудку. Буду действовать по-своему.	# actor:bandit # voiceover:24_ne_hochu_plyasat.ogg
* 	(companion_xenia) [Идти с Ксенией.]
	Ксения, пойдём вместе. Макс, присоединяйся.	# actor:player # voiceover:130_Xenia_poydom_vmeste.ogg
	Я решил, пойду один. Когда найду золото, обещаю не забирать всё. Оставлю и вам немного.	# actor:bandit # voiceover:25_ya_poydu_odin.ogg
	~ party_bandit = false
* 	(companion_max) [Идти с Максом.]
	Твой подход, Макс, мне кажется надёжнее, но я не могу позволить Ксении идти одной.	# actor:player # voiceover:131_tvoy_podhod_Max_mne.ogg
	Если хочешь, Андреас, отправляйся с Максом. Ты не обязан меня охранять. Мне ещё нужно посмотреть Парфенон и Кносский дворец.	# actor:female # voiceover:227_esli_hochesh_Andreas_otpravlaysa.ogg
	Разве тебе не любопытно какие загадки  скрывает этот лабиринт? Ты сейчас делаешь вид что уйдёшь, а сама будешь идти за нами.	# actor:player # voiceover:132_razve_tebe_ne_lubopytno.ogg
	Нет, я просто вернусь сюда одна когда вы уйдёте. Да шучу я! Просто дождусь паром и уплыву, честно. Только у меня есть одно условие. Андреас, обещай что позвонишь мне когда найдёшь артефакт своей мечты, чтобы рассказать какой он. Вот мой телефон.	# actor:female # voiceover:228_net_prosto_ya_vernus_suda.ogg
	Позвоню, обещаю.	# actor:player # voiceover:133_pozvonu_obeshayu.ogg
	Удачи. Вам обоим.	# actor:female # voiceover:229_udachi_vam_oboim.ogg
	~ party_female = false
* 	[Идти одному.]
	Сложный выбор, пойду один, как и планировал с самого начала.	# actor:player # voiceover:986_ya_reshil_poydu_odin.ogg
	Андреас, только я знаю древнегреческий язык и мифологию.	# actor:female # voiceover:andreas_tolko_ya.ogg
	Андреас, ты уверен, что один справишься?	# actor:bandit # voiceover:752_Andreas_ty_uveren_chto_odin.ogg 
	* * 	[Идти с Ксенией.]
		-> companion_xenia
	* * 	[Идти с Максом.]
		-> companion_max
	* * 	[Идти одному.]
		Я решил, пойду один.	# actor:player # voiceover:986_ya_reshil_poydu_odin.ogg
		~ party_bandit = false
		~ party_female = false