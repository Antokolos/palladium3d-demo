VAR party_female = true
VAR party_bandit = true
Вы поняли, насколько здесь опасно? Уверены, что стоит продолжать?	# actor:player
Я пойду дальше. Но только один.	# actor:bandit # voiceover:20_ya_poydu_dalshe.ogg
Одному здесь вдвойне опасней.	# actor:player
А с вами втройне опасней.	# actor:bandit # voiceover:21_vtroyne_opasney
Понятно на кого намёк. Идите вместе, а я сама справлюсь. Уверена что моих знаний хватит чтобы пройти ловушки.	# actor:female
Надо идти всем вместе. Уверен, что впредь каждый из нас будет максимально осторожен.	# actor:player
Вы скорее всего захотите рассказывать легенды, разгадывать загадки, а у меня другой подход.	# actor:bandit # voiceover:22_rasskazyvat_legendy.ogg
Думаю мы сможем договориться.	# actor:player
Когда ловушка сработает, времени на болтовню не будет.	# actor:bandit # voiceover:23_kogda_lovushka_srabotaet.ogg
Очевидно, что в каждой комнате есть загадка. Скорее всего это общий принцип. Зная правила, сможем выиграть.	# actor:female
Не хочу плясать под чью-то древнюю дудку. Буду действовать по-своему.	# actor:bandit # voiceover:24_ne_hochu_plyasat.ogg
* 	[Идти с Ксенией.]
	Ксения, пойдём вместе. Макс, присоединяйся.	# actor:player
	Я решил, пойду один. Когда найду золото, обещаю не забирать всё. Оставлю и вам немного.	# actor:bandit # voiceover:25_ya_poydu_odin
	~ party_bandit = false
* 	[Идти с Максом.]
	Твой подход, Макс, мне кажется надёжнее, но я не могу позволить Ксении идти одной.	# actor:player
	Если хочешь, Андреас, отправляйся с Максом. Ты не обязан меня охранять. Мне ещё нужно посмотреть Парфенон и Кносский дворец.	# actor:female
	Разве тебе не любопытно какие загадки  скрывает этот лабиринт? Ты сейчас делаешь вид что уйдёшь, а сама будешь идти за нами.	# actor:player
	Нет, я просто вернусь сюда одна когда вы уйдёте. Да шучу я! Просто дождусь паром и уплыву, честно. Только у меня есть одно условие. Андреас, обещай что позвонишь мне когда найдёшь артефакт своей мечты, чтобы рассказать какой он. Вот мой телефон.	# actor:female
	Позвоню, обещаю.	# actor:player
	Удачи. Вам обоим.	# actor:female
	~ party_female = false