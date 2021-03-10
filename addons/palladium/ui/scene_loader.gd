extends TextureRect

onready var progress = get_node("VBoxContainer/HBoxContainer/VBoxContainer/TextureProgress")
onready var label = get_node("VBoxContainer/HBoxContainer/VBoxContainer/ProgressLabel")
var loader = null

func _ready():
	if SCENES.DATA.has(game_state.scene_path):
		var scene_data = SCENES.DATA.get(game_state.scene_path)
		if scene_data.has("progress") and not scene_data.progress:
			get_tree().change_scene(game_state.scene_path)
			return
		if scene_data.has("splash"):
			set_texture(scene_data.splash)
	get_tree().paused = true
	common_utils.show_mouse_cursor_if_needed(false)
	MEDIA.change_music_to(MEDIA.MusicId.LOADING)
	loader = ResourceLoader.load_interactive(game_state.scene_path)

func _exit_tree():
	get_tree().paused = false

func _process(delta):
	if not loader:
		return
	progress.max_value = loader.get_stage_count()
	var err = loader.poll()
	if err == ERR_FILE_EOF:
		var pscn = loader.get_resource()
		loader = null
		game_state.cleanup_paths()
		get_tree().change_scene_to(pscn)
	else:
		progress.value = loader.get_stage()
		label.text = "%d%%" % floor(progress.value * 100.0 / progress.max_value)
