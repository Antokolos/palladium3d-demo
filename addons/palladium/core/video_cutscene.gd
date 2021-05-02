extends ColorRect

signal video_cutscene_finished(video_file_name)

onready var video_player = get_node("VBoxContainer/HBoxContainer/VideoPlayer")

func _ready():
	visible = false

func play(video_file_name):
	game_state.get_hud().pause_game(true, false)
	visible = true
	var stream = VideoStreamWebm.new()
	stream.set_file(video_file_name)
	video_player.stream = stream
	video_player.play()

func is_playing():
	return video_player.is_playing()

func _on_VideoPlayer_finished():
	visible = false
	game_state.get_hud().pause_game(false, false)
	emit_signal(
		"video_cutscene_finished",
		video_player.stream.get_file() if video_player.stream else null
	)