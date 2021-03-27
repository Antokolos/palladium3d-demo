extends PLDLevel

func do_init(is_loaded):
	game_state.set_player_name_hint(CHARS.PLAYER_NAME_HINT)
	$intro_phone.phone_idle()
	$male_bag.being_carried()
	$male_intro.start()
	get_node("camera_intro/Camera").run_camera_1()
	game_state.connect("shader_cache_processed", self, "_on_shader_cache_processed")
	conversation_manager.connect("conversation_finished", self, "_on_conversation_finished")
	$male_intro.connect("cutscene_finished", self, "_on_cutscene_finished")

func _on_conversation_finished(player, conversation_name, target, initiator, last_result):
	match conversation_name:
		"024_Phone":
			get_node("camera_intro/Camera").run_camera_2()
			$male_intro.walks_room()
			$intro_door_1.anim_start()
			$father.put_phone_down()
			$intro_phone.phone_put_down()
		"025_Andreas_return":
			game_state.change_scene("res://forest.tscn", false, true)

func _on_shader_cache_processed():
	conversation_manager.start_area_conversation("024_Phone")

func _on_cutscene_finished(player, player_model, cutscene_id, was_active):
	get_node("camera_intro/Camera").run_camera_3()
	conversation_manager.start_area_conversation("025_Andreas_return")