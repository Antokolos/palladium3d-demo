extends Navigation

func _ready():
	$player.take("saffron_bun", null)
	TranslationServer.set_locale("ru")
