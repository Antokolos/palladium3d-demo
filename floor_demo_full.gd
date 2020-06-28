extends Spatial

export var doors_path = "../../doors/floor_demo_full"
onready var doors = get_node(doors_path)
onready var erida_trap_sound_1 = get_node("Erida_room/EridaTrapSound1")
onready var erida_trap_sound_2 = get_node("Erida_room/EridaTrapSound2")
onready var erida_trap_sound_3 = get_node("Erida_room/EridaTrapSound3")
onready var erida_trap_sound_4 = get_node("Erida_room/EridaTrapSound4")
var gas_injury_rate = 1

func _ready():
	restore_state()
	conversation_manager.connect("conversation_finished", self, "_on_conversation_finished")
	conversation_manager.connect("meeting_finished", self, "_on_meeting_finished")
	conversation_manager.connect("conversation_started", self, "_on_conversation_started")
	var chest = get_node("Apata_room/apata_chest")
	chest.connect("was_translated", self, "_on_ChestArea_body_exited")
	$destructible_web.connect("web_destroyed", self, "_on_web_destroyed")
	get_tree().call_group("takables", "connect_signals", self)
	get_tree().call_group("pedestals", "connect_signals", self)
	get_tree().call_group("button_activators", "connect_signals", self)
	game_params.connect("player_registered", self, "_on_player_registered")
	get_door("door_0").connect("door_state_changed", self, "_on_door_state_changed")

func get_door(door_path):
	return doors.get_node(door_path)

func use_takable(player_node, takable, parent, was_taken):
	var takable_id = takable.takable_id
	var pedestal_id = parent.pedestal_id if parent is Pedestal else Pedestal.PedestalIds.NONE
	match takable_id:
		Takable.TakableIds.APATA:
			pass # door_0 is now closed a little bit later, when FEMALE_TAKES_APATA cutscene or corresponding dialogue is ended
		Takable.TakableIds.HERMES:
			match pedestal_id:
				Pedestal.PedestalIds.ERIDA_LOCK:
					get_door("door_8").close()
				Pedestal.PedestalIds.HERMES_FLAT:
					var door = get_door("door_5")
					var was_opened = door.is_opened()
					door.open()
					if not was_opened:
						game_params.autosave_create()
		Takable.TakableIds.ERIDA:
			match pedestal_id:
				Pedestal.PedestalIds.ERIS_FLAT:
					if game_params.story_vars.erida_trap_stage == game_params.EridaTrapStages.ARMED:
						get_door("door_8").close()
						conversation_manager.start_area_conversation("015-1_EridaTrap" if game_params.party[game_params.FEMALE_NAME_HINT] else "021-1_EridaTrapMax")
						game_params.story_vars.erida_trap_stage = game_params.EridaTrapStages.ACTIVE
						$EridaTrapTimer.start()
						erida_trap_play_sound()
		Takable.TakableIds.ARES:
			match pedestal_id:
				Pedestal.PedestalIds.ARES_FLAT:
					var door = get_door("door_6")
					var was_opened = door.is_opened()
					door.open()
					if not was_opened:
						game_params.autosave_create()

func erida_trap_play_sound():
	erida_trap_sound_1.play()
	erida_trap_sound_2.play()
	erida_trap_sound_3.play()
	erida_trap_sound_4.play()

func erida_trap_increase_sound_volume():
	var v1 = erida_trap_sound_1.get_unit_db()
	erida_trap_sound_1.set_unit_db(v1 / 2)
	var v2 = erida_trap_sound_2.get_unit_db()
	erida_trap_sound_2.set_unit_db(v2 / 2)
	var v3 = erida_trap_sound_3.get_unit_db()
	erida_trap_sound_3.set_unit_db(v3 / 2)
	var v4 = erida_trap_sound_4.get_unit_db()
	erida_trap_sound_4.set_unit_db(v4 / 2)

func erida_trap_stop_sound():
	erida_trap_sound_1.stop()
	erida_trap_sound_2.stop()
	erida_trap_sound_3.stop()
	erida_trap_sound_4.stop()

func check_demo_finish():
	var statues = get_tree().get_nodes_in_group("demo_finish_statues")
	for statue in statues:
		if not statue.is_present():
			return
	get_door("door_demo").open()
	conversation_manager.start_area_conversation("019_DemoFinishedXenia" if game_params.party[game_params.FEMALE_NAME_HINT] else "022-1_DemoFinishedMax")

func use_pedestal(player_node, pedestal, item_nam):
	var pedestal_id = pedestal.pedestal_id
	match pedestal_id:
		Pedestal.PedestalIds.APATA:
			if game_params.story_vars.apata_trap_stage != GameParams.ApataTrapStages.GOING_DOWN:
				return
			if game_params.story_vars.apata_chest_rigid < 0:
				return
			var hope = hope_on_apata_pedestal(pedestal)
			if item_nam == "statue_apata" and hope:
				get_node("Apata_room/door_3").open()
				get_node("Apata_room/ceiling_moving_1").pause()
				var female = game_params.get_character(game_params.FEMALE_NAME_HINT)
				female.join_party()
				var bandit = game_params.get_character(game_params.BANDIT_NAME_HINT)
				bandit.join_party()
		Pedestal.PedestalIds.MUSES:
			if has_empty_muses_pedestal(pedestal.get_parent()):
				return
			if not check_muses_correct(pedestal.get_parent()):
				conversation_manager.start_area_conversation("010-1-3_ApataMusesError")
				get_node("Apata_room/ceiling_moving_1").activate_partial()
				return
			conversation_manager.start_area_conversation("010-1-4_ApataDoneXenia")
			get_door("door_4").open()
			get_node("Apata_room/ceiling_moving_1").deactivate()
			get_node("Apata_room/door_3").close()
		Pedestal.PedestalIds.ERIDA_LOCK:
			get_door("door_8").open()
		Pedestal.PedestalIds.DEMO_ARES:
			check_demo_finish()
		Pedestal.PedestalIds.DEMO_HERMES:
			check_demo_finish()

func use_button_activator(player_node, button_activator):
	var activator_id = button_activator.activator_id
	match activator_id:
		ButtonActivator.ButtonActivatorIds.ERIDA:
			if game_params.story_vars.erida_trap_stage == game_params.EridaTrapStages.ACTIVE:
				var postaments = get_tree().get_nodes_in_group("erida_postaments")
				for postament in postaments:
					if not postament.is_state_correct():
						conversation_manager.start_area_conversation("015-2_EridaError" if game_params.party[game_params.FEMALE_NAME_HINT] else "021-2_EridaErrorMax")
						erida_trap_increase_sound_volume()
						$EridaButtonWrong.play()
						return
				$EridaButtonCorrect.play()
				get_door("door_7").open()
				conversation_manager.start_area_conversation("016_EridaDone" if game_params.party[game_params.FEMALE_NAME_HINT] else "021-3_EridaDoneMax")
				game_params.story_vars.erida_trap_stage = game_params.EridaTrapStages.DISABLED
				$EridaTrapTimer.stop()
				erida_trap_stop_sound()

func hope_on_apata_pedestal(pedestal):
	for ch in pedestal.get_children():
		if (ch is Takable) and ch.is_present() and ch.takable_id == Takable.TakableIds.SPHERE_FOR_POSTAMENT:
			return true
	return false

func check_pedestal(pedestal, takable_id):
	var correct = false
	if not pedestal:
		return false
	for ch in pedestal.get_children():
		if (ch is Takable) and ch.is_present():
			if ch.has_id(takable_id):
				correct = true
			else:
				return false
	return correct

func has_empty_muses_pedestal(base):
	var pedestal_theatre = base.get_node("pedestal_theatre")
	var pedestal_astronomy = base.get_node("pedestal_astronomy")
	var pedestal_history = base.get_node("pedestal_history")
	return pedestal_theatre.is_empty() or pedestal_astronomy.is_empty() or pedestal_history.is_empty()

func check_muses_correct(base):
	var pedestal_theatre = base.get_node("pedestal_theatre")
	if not check_pedestal(pedestal_theatre, Takable.TakableIds.MELPOMENE):
		return false
	var pedestal_astronomy = base.get_node("pedestal_astronomy")
	if not check_pedestal(pedestal_astronomy, Takable.TakableIds.URANIA):
		return false
	var pedestal_history = base.get_node("pedestal_history")
	return check_pedestal(pedestal_history, Takable.TakableIds.CLIO)

func _on_AreaApata_body_entered(body):
	if game_params.story_vars.apata_trap_stage == game_params.ApataTrapStages.ARMED and body.is_in_group("party") and body.is_player():
		var female = game_params.get_character(game_params.FEMALE_NAME_HINT)
		female.teleport(get_node("PositionApata"))
		var bandit = game_params.get_character(game_params.BANDIT_NAME_HINT)
		bandit.teleport(get_node("BanditSavePosition"))
		body.teleport(get_node("PlayerTeleportPosition"))
		get_node("ApataTakeTimer").start()
		female.play_cutscene(PLDFemaleModel.FEMALE_TAKES_APATA)
		conversation_manager.start_area_cutscene("009_ApataTrap", get_node("ApataCutscenePosition"))

func _on_ApataTakeTimer_timeout():
	var female = game_params.get_character(game_params.FEMALE_NAME_HINT)
	var apata_statue = get_node("Apata_room/pedestal_apata/statue_4")
	apata_statue.use(female, null)

func _on_AreaMuses_body_entered(body):
	if game_params.story_vars.apata_trap_stage == game_params.ApataTrapStages.PAUSED and body.is_in_group("party") and body.is_player():
		conversation_manager.start_area_conversation("010-1-1_Statuettes")

func _on_AreaApataDone_body_entered(body):
	if body.is_in_group("party") and body.is_player():
		conversation_manager.start_area_conversation("011_Hermes")

func _on_EridaTrapTimer_timeout():
	game_params.set_health(game_params.PLAYER_NAME_HINT, game_params.player_health_current - gas_injury_rate, game_params.player_health_max)

func _on_IgnitionArea_body_entered(body):
	var player = game_params.get_player()
	if body.is_in_group("party") and not conversation_manager.conversation_is_in_progress("004_TorchesIgnition") and conversation_manager.conversation_is_not_finished("004_TorchesIgnition"):
		$SoundIgnitionClick.play()
		get_tree().call_group("torches", "enable", true, false)
		conversation_manager.start_conversation(player, "004_TorchesIgnition")

func _on_RatsArea_body_entered(body):
	if body.is_in_group("party") and game_params.is_in_party(game_params.FEMALE_NAME_HINT):
		conversation_manager.start_area_conversation("006_Rats")

func _on_AreaDeadEnd_body_entered(body):
	if body.is_in_group("party") and game_params.is_in_party(game_params.FEMALE_NAME_HINT):
		conversation_manager.start_area_conversation("023_DemoDeadEnd")

func _on_AreaDeadEnd2_body_entered(body):
	if body.is_in_group("party") and game_params.is_in_party(game_params.FEMALE_NAME_HINT):
		conversation_manager.start_area_conversation("023_DemoDeadEnd")

func _on_web_destroyed(web):
	conversation_manager.start_area_cutscene("005_ApataInscriptions", get_node("InscriptionsPosition"))

func _on_ChooseCompanionArea_body_entered(body):
	if body.is_in_group("party"):
		if game_params.story_vars.erida_trap_stage == game_params.EridaTrapStages.ARMED and game_params.story_vars.apata_trap_stage == game_params.ApataTrapStages.DISABLED:
			var female = game_params.get_character(game_params.FEMALE_NAME_HINT)
			female.set_target_node(get_node("OutPosition"))
			var bandit = game_params.get_character(game_params.BANDIT_NAME_HINT)
			bandit.set_target_node(get_node("OutPosition"))
			conversation_manager.start_area_cutscene("012_ChooseCompanion", get_node("ChooseCompanionPosition"))
		elif game_params.story_vars.erida_trap_stage == game_params.EridaTrapStages.DISABLED:
			conversation_manager.start_area_conversation("018_CorridorTalk" if game_params.party[game_params.FEMALE_NAME_HINT] else "022_CorridorTalkMax")

func _on_BeforeEridaArea_body_entered(body):
	if body.is_in_group("party"):
		if game_params.story_vars.erida_trap_stage == game_params.EridaTrapStages.ARMED and game_params.story_vars.apata_trap_stage == game_params.ApataTrapStages.DISABLED:
			conversation_manager.start_area_conversation("014_BeforeErida" if game_params.party[game_params.FEMALE_NAME_HINT] else "020_BeforeEridaMax")
		elif game_params.story_vars.erida_trap_stage == game_params.EridaTrapStages.DISABLED and game_params.party[game_params.FEMALE_NAME_HINT]:
			conversation_manager.start_area_conversation("017_CorridorTraps")

func _on_BeginEridaArea_body_entered(body):
	if body.is_in_group("party"):
		conversation_manager.start_area_conversation("015_BeginErida" if game_params.party[game_params.FEMALE_NAME_HINT] else "021_BeginEridaMax")

func _on_AresRoomArea_body_entered(body):
	if body.is_in_group("party") and game_params.is_in_party(game_params.FEMALE_NAME_HINT):
		conversation_manager.start_area_conversation("016-1_AresRoom")

func _on_ChestArea_body_exited(body):
	if game_params.story_vars.apata_chest_rigid > 0 and body is ApataChest and body.container_id == ItemContainer.ContainerIds.APATA_CHEST and game_params.story_vars.apata_trap_stage == game_params.ApataTrapStages.GOING_DOWN:
		game_params.story_vars.apata_chest_rigid = -1
		var player = game_params.get_player()
		cutscene_manager.restore_camera(player)
		var bandit = game_params.get_character(game_params.BANDIT_NAME_HINT)
		var female = game_params.get_character(game_params.FEMALE_NAME_HINT)
		player.stop_cutscene()
		bandit.stop_cutscene()
		player.join_party()
		conversation_manager.start_area_conversation("010-2-1_ChestMoved")
		bandit.set_target_node(get_node("BanditSavePosition"))
		female.set_target_node(get_node("FemaleSavePosition"))

func _on_conversation_started(player, conversation_name, target, initiator):
	match conversation_name:
		"010-2-4_ApataDoneMax":
			get_door("door_4").open()
			#get_node("Apata_room/door_3").close()

func _on_player_registered(player):
	player.connect("arrived_to", self, "_on_arrived_to")
	player.get_model().connect("cutscene_finished", self, "_on_cutscene_finished")

func _on_cutscene_finished(player, cutscene_id):
	match player.name_hint:
		game_params.FEMALE_NAME_HINT:
			match cutscene_id:
				PLDFemaleModel.FEMALE_TAKES_APATA:
					if conversation_manager.conversation_is_not_finished("009_ApataTrap"):
						var p = game_params.get_player()
						cutscene_manager.restore_camera(p)
						cutscene_manager.borrow_camera(p, get_node("ApataDoorPosition"))
					if game_params.story_vars.apata_trap_stage == game_params.ApataTrapStages.ARMED:
						get_door("door_0").close()
						get_node("Apata_room/ceiling_moving_1").ceiling_sound_play()
					player.remove_item_from_hand()
					player.set_target_node(get_node("PositionApata2"))
					return

func _on_conversation_finished(player, conversation_name, target, initiator):
	var bandit = game_params.get_character(game_params.BANDIT_NAME_HINT)
	var female = game_params.get_character(game_params.FEMALE_NAME_HINT)
	match conversation_name:
		"005_ApataInscriptions":
			bandit.teleport(get_node("BanditPosition"))
			conversation_manager.arrange_meeting(player, player, bandit, true, get_node("InscriptionsPosition"))
		"009_ApataTrap":
			get_door("door_0").close() # Close the door if it is not already closed
			get_node("Apata_room/ceiling_moving_1").activate()
			female.set_target_node(get_node("PositionApata3"))
			if game_params.story_vars.apata_chest_rigid > 0:
				player.set_target_node(get_node("PlayerIntermediatePosition"))
				player.leave_party()
				cutscene_manager.borrow_camera(player, get_node("ApataCutscenePosition"))
		"010-2-1_ChestMoved":
			bandit.sit_down()
			female.sit_down()
			game_params.get_hud().queue_popup_message("MESSAGE_CONTROLS_CROUCH", ["C"])
		"010-1-1_Statuettes", "015-1_EridaTrap", "021-1_EridaTrapMax":
			game_params.get_hud().queue_popup_message("MESSAGE_CONTROLS_DIALOGUE_1")
			game_params.get_hud().queue_popup_message("MESSAGE_CONTROLS_DIALOGUE_2")

func _on_meeting_finished(player, target, initiator):
	if initiator and initiator.name_hint == game_params.BANDIT_NAME_HINT:
		initiator.set_target_node(get_node("BanditSavePosition"))
		initiator.leave_party()
		var female = game_params.get_character(game_params.FEMALE_NAME_HINT)
		female.set_target_node(get_node("PositionApata"))
		female.leave_party()
		game_params.autosave_create()

func _on_door_state_changed(door_id, opened):
	match door_id:
		Door.DoorIds.APATA_TRAP_INNER:
			if not opened and game_params.story_vars.apata_trap_stage == game_params.ApataTrapStages.ARMED and conversation_manager.conversation_is_not_finished("009_ApataTrap"):
				var player = game_params.get_player()
				cutscene_manager.restore_camera(player)
				cutscene_manager.borrow_camera(player, get_node("ApataCutscenePosition"))

func _on_arrived_to(player_node, target_node):
	if game_params.story_vars.apata_chest_rigid <= 0:
		return
	var tid = target_node.get_instance_id()
	var player = game_params.get_character(game_params.PLAYER_NAME_HINT)
	var female = game_params.get_character(game_params.FEMALE_NAME_HINT)
	var piid = get_node("PlayerIntermediatePosition").get_instance_id()
	var pa3id = get_node("PositionApata3").get_instance_id()
	if tid == piid and player.get_instance_id() == player_node.get_instance_id():
		player.set_target_node(get_node("PlayerSavePosition"))
		return
	elif tid == pa3id and female.get_instance_id() == player_node.get_instance_id():
		female.set_target_node(get_node("FemaleSavePosition"))
		return
	var bandit = game_params.get_character(game_params.BANDIT_NAME_HINT)
	var pid = get_node("PlayerSavePosition").get_instance_id()
	var bid = get_node("BanditSavePosition").get_instance_id()
	if (tid == pid or tid == bid) and player.is_rest_state() and bandit.is_rest_state():
		bandit.play_cutscene(PLDBanditModel.BANDIT_CUTSCENE_PUSHES_CHEST_START)
		player.play_cutscene(PLDMaleModel.PLAYER_CUTSCENE_PUSHES_CHEST)
		var chest = get_node("Apata_room/apata_chest")
		chest.do_push()

func restore_state():
	if game_params.story_vars.erida_trap_stage == game_params.EridaTrapStages.ACTIVE:
		$EridaTrapTimer.start()
	else:
		$EridaTrapTimer.stop()
