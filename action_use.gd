extends Spatial

onready var ray = $Ray_Cast
var action_body = null

func action(player_node):
	ray.force_raycast_update()
	
	if ray.is_colliding():
		var body = ray.get_collider()
		if body == player_node:
			pass
		elif body.has_method("use"):
			body.use(player_node)

func switch_highlight(player_node, body):
	if action_body == body:
		return
	if action_body:
		var ref = action_body.get_ref()
		if ref and ref.has_method("remove_highlight"):
			ref.remove_highlight(player_node)
		var hints = player_node.get_hud().hints
		player_node.get_hud().alt_hint.text = ""
		hints.get_node("HBoxContainer/ActionHintLabel").text = ""
	if body and body.has_method("add_highlight"):
		var hint_message = body.add_highlight(player_node)
		var hints = player_node.get_hud().hints
		if hints.visible:
			hints.get_node("HBoxContainer/ActionHintLabel").text = hint_message
		else:
			hints.get_node("HBoxContainer/ActionHintLabel").text = ""
			player_node.get_hud().alt_hint.text = hint_message
	action_body = weakref(body) if body else null

func highlight(player_node):
	# ray.force_raycast_update() -- do not using this, because we'll call this during _physics_process
	if ray.is_colliding():
		var body = ray.get_collider()
		if body == player_node:
			switch_highlight(player_node, null)
		else:
			switch_highlight(player_node, body)
	else:
		switch_highlight(player_node, null)