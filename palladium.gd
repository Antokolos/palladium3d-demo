extends Navigation

var player_toggle_enable = true

func _ready():
	$player.take("saffron_bun", null)
	TranslationServer.set_locale("ru")

func _unhandled_input(event):
	if not player_toggle_enable:
		return
	var player = get_node("player")
	var player_female = get_node("player_female")
	if event is InputEventKey:
		match event.scancode:
			KEY_9:
				player.become_player()
			KEY_0:
				player_female.become_player()