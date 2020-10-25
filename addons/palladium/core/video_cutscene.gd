extends ColorRect

onready var video_player = get_node("VBoxContainer/HBoxContainer/VideoPlayer")

func _ready():
	visible = false

func play(video_file_name):
	get_tree().paused = true
	visible = true
	var stream = VideoStreamWebm.new()
	stream.set_file(video_file_name)
	video_player.stream = stream
	video_player.play()

func _on_VideoPlayer_finished():
	visible = false
	get_tree().paused = false