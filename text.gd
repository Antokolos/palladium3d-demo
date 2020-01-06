extends Spatial

export var locale = "ru"
export var locale_inverted = false

func _ready():
	settings.connect("language_changed", self, "handle_language_changes")
	handle_language_changes(settings.language)

func handle_language_changes(lang_id):
	var v = TranslationServer.get_locale() == locale
	visible = not v if locale_inverted else v
