extends Spatial

export var doors_path = "../../doors/floor_demo_full"

const INSCRIPTIONS_DIALOGUES = [
	'005_ApataInscriptions', # Every riddle has a solution, Only two can pass the trials
	'010-1-2_MusesHint', # Reveal the deception and restore the truth
	'029_Goddes_will_tame', # When the goddess will tame the wild beast, they will step back
	'068_Sun_competitors', # Get rid of the Sun's competitors
	'113_Coin_depicted', # this is the letter "P"
	'152_A_sign_appeared', # Zeus's children will show the way
	'157_The_birth_of_Athena', # The birth of Athena
	'174_This_inscription_wasn\'t', # Name three bird companions of Athena, Hera, and Aphrodite into the iron ear
	'179-2_Tablets', # Before picking one of the jars, you can check the contents only of one of them. And remember: tablet drawings lie
	'195_ambrosia_cup_female', # Pour some water in the evening. In the morning the water will become ambrosia.
	'196_trick_Zeus' # Trick Zeus
]

onready var doors = get_node(doors_path)
onready var last_trap_postament = get_node("last_trap_postament")
onready var last_trap_spikes = get_node("last_trap_spikes")
onready var zheleznoe_uho = get_node("4_Zheleznoe_uho")
onready var floor_demo_blocks_floor = get_node("floor_demo_blocks_floor")

func _ready():
	conversation_manager.connect("conversation_finished", self, "_on_conversation_finished")
	conversation_manager.connect("meeting_finished", self, "_on_meeting_finished")
	conversation_manager.connect("conversation_started", self, "_on_conversation_started")
	var chest = get_node("Apata_room/apata_chest")
	chest.connect("was_translated", self, "_on_ChestArea_body_exited")
	$destructible_web.connect("web_destroyed", self, "_on_web_destroyed")
	get_tree().call_group("lootables", "connect_signals", self)
	get_tree().call_group("takables", "connect_signals", self)
	get_tree().call_group("pedestals", "connect_signals", self)
	get_tree().call_group("button_activators", "connect_signals", self)
	game_state.connect("player_registered", self, "_on_player_registered")
	get_door("door_0").connect("door_state_changed", self, "_on_door_state_changed")

func get_door(door_path):
	return doors.get_node(door_path)

func use_lootable(player_node, lootable):
	var takable_id = lootable.takable_id
	match takable_id:
		DB.TakableIds.COIN:
			if game_state.is_in_party(CHARS.BANDIT_NAME_HINT):
				conversation_manager.start_area_conversation("193_some_gold_after_all")

func use_takable(player_node, takable, parent, was_taken):
	var takable_id = takable.takable_id
	var pedestal_id = parent.pedestal_id if parent is PLDPedestal else DB.PedestalIds.NONE
	match takable_id:
		DB.TakableIds.APATA:
			if was_taken:
				PREFS.set_achievement("APATE")
			pass # door_0 is now closed a little bit later, when FEMALE_CUTSCENE_TAKES_APATA cutscene or corresponding dialogue is ended
		DB.TakableIds.HERMES:
			if was_taken:
				PREFS.set_achievement("HERMES")
			match pedestal_id:
				DB.PedestalIds.ERIDA_LOCK:
					get_door("door_8").close()
				DB.PedestalIds.HERMES_FLAT:
					var door = get_door("door_5")
					var was_opened = door.is_opened()
					door.open()
					if not was_opened:
						game_state.autosave_create()
		DB.TakableIds.ERIDA:
			if was_taken:
				PREFS.set_achievement("ERIS")
			match pedestal_id:
				DB.PedestalIds.ERIS_FLAT:
					var erida_trap = game_state.get_activatable(DB.ActivatableIds.ERIDA_TRAP)
					if erida_trap and erida_trap.is_untouched():
						get_door("door_8").close()
						erida_trap.activate()
						conversation_manager.start_area_conversation_with_companion({
							CHARS.FEMALE_NAME_HINT : "015-1_EridaTrap",
							CHARS.BANDIT_NAME_HINT : "021-1_EridaTrapMax"
						})
		DB.TakableIds.ARES:
			if was_taken:
				PREFS.set_achievement("ARES")
			match pedestal_id:
				DB.PedestalIds.ARES_FLAT:
					var door = get_door("door_6")
					var was_opened = door.is_opened()
					door.open()
					if not was_opened:
						game_state.autosave_create()
		DB.TakableIds.ATHENA:
			if was_taken:
				PREFS.set_achievement("ANCIENT_ARTIFACT")
			last_trap_show()

func last_trap_show():
	last_trap_postament.visible = true
	last_trap_spikes.visible = true
	zheleznoe_uho.visible = true
	floor_demo_blocks_floor.visible = false

func last_trap_hide():
	last_trap_postament.visible = false
	last_trap_spikes.visible = false
	zheleznoe_uho.visible = false
	floor_demo_blocks_floor.visible = true

func check_demo_finish():
	var statues = get_tree().get_nodes_in_group("demo_finish_statues")
	for statue in statues:
		if not statue.is_present():
			return
	get_door("door_demo").open()
	conversation_manager.start_area_conversation_with_companion({
		CHARS.FEMALE_NAME_HINT : "019_DemoFinishedXenia",
		CHARS.BANDIT_NAME_HINT : "022-1_DemoFinishedMax"
	})

func use_pedestal(player_node, pedestal, inventory_item, child_item):
	var item_id = inventory_item.item_id
	var pedestal_id = pedestal.pedestal_id
	match pedestal_id:
		DB.PedestalIds.APATA:
			if game_state.get_activatable_state_by_id(DB.ActivatableIds.APATA_TRAP) != PLDGameState.ActivatableState.ACTIVATED:
				return
			if game_state.story_vars.apata_chest_rigid < 0:
				return
			var hope = hope_on_apata_pedestal(pedestal)
			if item_id == DB.TakableIds.APATA and hope:
				get_node("Apata_room/door_3").open()
				get_node("Apata_room/ceiling_moving_1").pause()
				var female = game_state.get_character(CHARS.FEMALE_NAME_HINT)
				female.join_party()
				var bandit = game_state.get_character(CHARS.BANDIT_NAME_HINT)
				bandit.join_party()
		DB.PedestalIds.MUSES:
			if has_empty_muses_pedestal(pedestal.get_parent()):
				return
			if not check_muses_correct(pedestal.get_parent()):
				conversation_manager.start_area_conversation("010-1-3_ApataMusesError")
				get_node("Apata_room/ceiling_moving_1").activate_partial()
				return
			conversation_manager.start_area_conversation("010-1-4_ApataDoneXenia")
			get_door("door_4").open()
			game_state.get_activatable(DB.ActivatableIds.APATA_TRAP).deactivate_forever()
			get_node("Apata_room/door_3").close()
		DB.PedestalIds.ERIDA_LOCK:
			get_door("door_8").open()
		DB.PedestalIds.DEMO_ARES:
			check_demo_finish()
		DB.PedestalIds.DEMO_HERMES:
			check_demo_finish()
		DB.PedestalIds.ZEUS_ATHENA:
			if item_id == DB.TakableIds.ATHENA:
				last_trap_hide()

func use_button_activator(player_node, button_activator):
	var activator_id = button_activator.activator_id
	match activator_id:
		DB.ButtonActivatorIds.ERIDA:
			var erida_trap = game_state.get_activatable(DB.ActivatableIds.ERIDA_TRAP)
			if erida_trap and erida_trap.is_activated():
				var postaments = get_tree().get_nodes_in_group("erida_postaments")
				for postament in postaments:
					if not postament.is_state_correct():
						conversation_manager.start_area_conversation_with_companion({
							CHARS.FEMALE_NAME_HINT : "015-2_EridaError",
							CHARS.BANDIT_NAME_HINT : "021-2_EridaErrorMax"
						})
						erida_trap.increase_sound_volume()
						$EridaButtonWrong.play()
						return
				$EridaButtonCorrect.play()
				get_door("door_7").open()
				conversation_manager.start_area_conversation_with_companion({
					CHARS.FEMALE_NAME_HINT : "016_EridaDone",
					CHARS.BANDIT_NAME_HINT : "021-3_EridaDoneMax"
				})
				erida_trap.deactivate_forever()

func hope_on_apata_pedestal(pedestal):
	for ch in pedestal.get_children():
		if (ch is PLDTakable) and ch.is_present() and ch.takable_id == DB.TakableIds.SPHERE_FOR_POSTAMENT:
			return true
	return false

func check_pedestal(pedestal, takable_id):
	var correct = false
	if not pedestal:
		return false
	for ch in pedestal.get_children():
		if (ch is PLDTakable) and ch.is_present():
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
	if not check_pedestal(pedestal_theatre, DB.TakableIds.MELPOMENE):
		return false
	var pedestal_astronomy = base.get_node("pedestal_astronomy")
	if not check_pedestal(pedestal_astronomy, DB.TakableIds.URANIA):
		return false
	var pedestal_history = base.get_node("pedestal_history")
	return check_pedestal(pedestal_history, DB.TakableIds.CLIO)

func _on_AreaApata_body_entered(body):
	var apata_trap = game_state.get_activatable(DB.ActivatableIds.APATA_TRAP)
	if apata_trap \
		and apata_trap.is_untouched() \
		and body.is_in_group("party") \
		and body.is_player():
		var female = game_state.get_character(CHARS.FEMALE_NAME_HINT)
		female.teleport(get_node("PositionApata"))
		var bandit = game_state.get_character(CHARS.BANDIT_NAME_HINT)
		bandit.teleport(get_node("BanditSavePosition"))
		body.teleport(get_node("PlayerTeleportPosition"))
		get_node("ApataTakeTimer").start()
		female.play_cutscene(FemaleModel.FEMALE_CUTSCENE_TAKES_APATA)
		conversation_manager.start_area_cutscene("009_ApataTrap", get_node("ApataCutscenePosition"))

func _on_ApataTakeTimer_timeout():
	var female = game_state.get_character(CHARS.FEMALE_NAME_HINT)
	var apata_statue = get_node("Apata_room/pedestal_apata/statue_4")
	apata_statue.use(female, null)

func _on_AreaMuses_body_entered(body):
	if game_state.get_activatable_state_by_id(DB.ActivatableIds.APATA_TRAP) == PLDGameState.ActivatableState.PAUSED and body.is_in_group("party") and body.is_player():
		conversation_manager.start_area_conversation("010-1-1_Statuettes")

func _on_AreaApataDone_body_entered(body):
	if body.is_in_group("party") and body.is_player():
		conversation_manager.start_area_conversation("011_Hermes")

func _on_IgnitionArea_body_entered(body):
	var player = game_state.get_player()
	if body.is_in_group("party") and not conversation_manager.conversation_is_in_progress("004_TorchesIgnition") and conversation_manager.conversation_is_not_finished("004_TorchesIgnition"):
		$SoundIgnitionClick.play()
		get_tree().call_group("torches", "enable", true, false)
		conversation_manager.start_conversation(player, "004_TorchesIgnition")

func _on_RatsArea_body_entered(body):
	if body.is_in_group("party") and game_state.is_in_party(CHARS.FEMALE_NAME_HINT):
		conversation_manager.start_area_conversation("006_Rats")

func _on_AreaDeadEnd_body_entered(body):
	if body.is_in_group("party") and game_state.is_in_party(CHARS.FEMALE_NAME_HINT):
		conversation_manager.start_area_conversation("023_DemoDeadEnd")

func _on_AreaDeadEnd2_body_entered(body):
	if body.is_in_group("party") and game_state.is_in_party(CHARS.FEMALE_NAME_HINT):
		conversation_manager.start_area_conversation("023_DemoDeadEnd")

func _on_web_destroyed(web):
	PREFS.set_achievement("COBWEB")
	if web.get_usable_id() == DB.UsableIds.WEB_APATA:
		conversation_manager.start_area_cutscene("005_ApataInscriptions", get_node("InscriptionsPosition"))

func _on_ChooseCompanionArea_body_entered(body):
	if body.is_in_group("party"):
		var erida_trap = game_state.get_activatable(DB.ActivatableIds.ERIDA_TRAP)
		if erida_trap \
			and erida_trap.is_untouched() \
			and game_state.get_activatable_state_by_id(DB.ActivatableIds.APATA_TRAP) == PLDGameState.ActivatableState.DEACTIVATED_FOREVER:
			var female = game_state.get_character(CHARS.FEMALE_NAME_HINT)
			female.set_target_node(get_node("OutPosition"))
			var bandit = game_state.get_character(CHARS.BANDIT_NAME_HINT)
			bandit.set_target_node(get_node("OutPosition"))
			conversation_manager.start_area_cutscene("012_ChooseCompanion", get_node("ChooseCompanionPosition"))
		elif game_state.get_activatable_state_by_id(DB.ActivatableIds.ERIDA_TRAP) == PLDGameState.ActivatableState.DEACTIVATED_FOREVER:
			conversation_manager.start_area_conversation_with_companion({
				CHARS.FEMALE_NAME_HINT : "018_CorridorTalk",
				CHARS.BANDIT_NAME_HINT : "022_CorridorTalkMax"
			})

func _on_BeforeEridaArea_body_entered(body):
	if body.is_in_group("party"):
		var erida_trap = game_state.get_activatable(DB.ActivatableIds.ERIDA_TRAP)
		if erida_trap \
			and erida_trap.is_untouched() \
			and game_state.get_activatable_state_by_id(DB.ActivatableIds.APATA_TRAP) == PLDGameState.ActivatableState.DEACTIVATED_FOREVER:
			conversation_manager.start_area_conversation_with_companion({
				CHARS.FEMALE_NAME_HINT : "014_BeforeErida",
				CHARS.BANDIT_NAME_HINT : "020_BeforeEridaMax"
			})
		elif game_state.get_activatable_state_by_id(DB.ActivatableIds.ERIDA_TRAP) == PLDGameState.ActivatableState.DEACTIVATED_FOREVER and game_state.is_in_party(CHARS.FEMALE_NAME_HINT):
			conversation_manager.start_area_conversation("017_CorridorTraps")

func _on_BeginEridaArea_body_entered(body):
	if body.is_in_group("party"):
		conversation_manager.start_area_conversation_with_companion({
			CHARS.FEMALE_NAME_HINT : "015_BeginErida",
			CHARS.BANDIT_NAME_HINT : "021_BeginEridaMax"
		})

func _on_AresRoomArea_body_entered(body):
	if body.is_in_group("party") and game_state.is_in_party(CHARS.FEMALE_NAME_HINT):
		conversation_manager.start_area_conversation("016-1_AresRoom")

func _on_ChestArea_body_exited(body):
	if game_state.story_vars.apata_chest_rigid > 0 and body is ApataChest and body.container_id == DB.ContainerIds.APATA_CHEST and game_state.get_activatable_state_by_id(DB.ActivatableIds.APATA_TRAP) == PLDGameState.ActivatableState.ACTIVATED and not game_state.is_loading():
		game_state.story_vars.apata_chest_rigid = -1
		var player = game_state.get_player()
		cutscene_manager.restore_camera(player)
		var bandit = game_state.get_character(CHARS.BANDIT_NAME_HINT)
		var female = game_state.get_character(CHARS.FEMALE_NAME_HINT)
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

func _on_cutscene_finished(player, player_model, cutscene_id, was_active):
	match player.name_hint:
		CHARS.FEMALE_NAME_HINT:
			match cutscene_id:
				FemaleModel.FEMALE_CUTSCENE_TAKES_APATA:
					if conversation_manager.conversation_is_not_finished("009_ApataTrap"):
						var p = game_state.get_player()
						cutscene_manager.restore_camera(p)
						cutscene_manager.borrow_camera(p, get_node("ApataDoorPosition"))
					var apata_trap = game_state.get_activatable(DB.ActivatableIds.APATA_TRAP)
					if apata_trap and apata_trap.is_untouched():
						get_door("door_0").close()
						get_node("Apata_room/ceiling_moving_1").ceiling_sound_play()
					player.remove_item_from_hand()
					player.set_target_node(get_node("PositionApata2"))
					return

func _on_conversation_finished(player, conversation_name, target, initiator, last_result):
	var bandit = game_state.get_character(CHARS.BANDIT_NAME_HINT)
	var female = game_state.get_character(CHARS.FEMALE_NAME_HINT)
	for dlg_name in INSCRIPTIONS_DIALOGUES:
		if dlg_name.casecmp_to(conversation_name) != 0:
			continue
		if PREFS.get_achievement("GREEK_LANGUAGE_LOVER", dlg_name) > 0:
			continue
		if story_node.visit_count_is_at_least([ dlg_name + ".ink.json"], 1):
			PREFS.set_achievement("GREEK_LANGUAGE_LOVER", dlg_name)
	match conversation_name:
		"005_ApataInscriptions":
			bandit.teleport(get_node("BanditPosition"))
			bandit.activate()
			conversation_manager.arrange_meeting(player, player, bandit, true, get_node("InscriptionsPosition"))
		"009_ApataTrap":
			get_door("door_0").close() # Close the door if it is not already closed
			get_node("Apata_room/ceiling_moving_1").activate()
			female.set_target_node(get_node("PositionApata3"))
			if game_state.story_vars.apata_chest_rigid > 0:
				player.set_target_node(get_node("PlayerIntermediatePosition"))
				player.leave_party()
				cutscene_manager.borrow_camera(player, get_node("ApataCutscenePosition"))
		"010-2-1_ChestMoved":
			bandit.sit_down()
			female.sit_down()
			game_state.get_hud().queue_popup_message("MESSAGE_CONTROLS_CROUCH", ["C"])
		"010-1-1_Statuettes", "015-1_EridaTrap", "021-1_EridaTrapMax":
			game_state.get_hud().queue_popup_message("MESSAGE_CONTROLS_DIALOGUE_1")
			game_state.get_hud().queue_popup_message("MESSAGE_CONTROLS_DIALOGUE_2")

func _on_meeting_finished(player, target, initiator):
	if initiator and initiator.name_hint == CHARS.BANDIT_NAME_HINT:
		initiator.set_target_node(get_node("BanditSavePosition"))
		initiator.leave_party()
		var female = game_state.get_character(CHARS.FEMALE_NAME_HINT)
		female.set_target_node(get_node("PositionApata"))
		female.leave_party()
		game_state.autosave_create()

func _on_door_state_changed(door_id, opened):
	match door_id:
		DB.DoorIds.APATA_TRAP_INNER:
			var apata_trap = game_state.get_activatable(DB.ActivatableIds.APATA_TRAP)
			if not opened \
				and apata_trap \
				and apata_trap.is_untouched() \
				and conversation_manager.conversation_is_not_finished("009_ApataTrap"):
				var player = game_state.get_player()
				cutscene_manager.restore_camera(player)
				cutscene_manager.borrow_camera(player, get_node("ApataCutscenePosition"))

func _on_arrived_to(player_node, target_node):
	var tid = target_node.get_instance_id()
	var oid = get_node("OutPosition").get_instance_id()
	if tid == oid and not player_node.is_in_party():
		player_node.set_hidden(true)
		player_node.deactivate()
	if game_state.story_vars.apata_chest_rigid <= 0:
		return
	var player = game_state.get_character(CHARS.PLAYER_NAME_HINT)
	var female = game_state.get_character(CHARS.FEMALE_NAME_HINT)
	var piid = get_node("PlayerIntermediatePosition").get_instance_id()
	var pa3id = get_node("PositionApata3").get_instance_id()
	if tid == piid and player.equals(player_node):
		player.set_target_node(get_node("PlayerSavePosition"))
		return
	elif tid == pa3id and female.equals(player_node):
		female.set_target_node(get_node("FemaleSavePosition"))
		return
	var bandit = game_state.get_character(CHARS.BANDIT_NAME_HINT)
	var pid = get_node("PlayerSavePosition").get_instance_id()
	var bid = get_node("BanditSavePosition").get_instance_id()
	if (tid == pid or tid == bid) and player.is_rest_state() and bandit.is_rest_state():
		bandit.play_cutscene(BanditModel.BANDIT_CUTSCENE_PUSHES_CHEST_START)
		player.play_cutscene(MaleModel.PLAYER_CUTSCENE_PUSHES_CHEST)
		var chest = get_node("Apata_room/apata_chest")
		chest.do_push()

func restore_state():
	if game_state.has_item(DB.TakableIds.ATHENA) or game_state.get_activatable_state_by_id(DB.ActivatableIds.LAST_TRAP_FLOOR) == PLDGameState.ActivatableState.ACTIVATED:
		last_trap_show()
	else:
		last_trap_hide()
