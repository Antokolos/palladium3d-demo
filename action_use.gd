extends Spatial

onready var ray = $Ray_Cast
var player_node = null
var action_body = null

func action():
	ray.force_raycast_update()
	
	if ray.is_colliding():
		var body = ray.get_collider()
		if body == player_node:
			pass
		elif body.has_method("use"):
			body.use(player_node)

func switch_highlight(body):
	if action_body == body:
		return
	if action_body and action_body.get_ref() and action_body.get_ref().has_method("remove_highlight"):
		action_body.get_ref().remove_highlight()
		get_node("../../../../HUD/Hints/HBoxContainer/ActionHintLabel").text = ""
	if body and body.has_method("add_highlight"):
		var hint_message = body.add_highlight()
		get_node("../../../../HUD/Hints/HBoxContainer/ActionHintLabel").text = hint_message
	action_body = weakref(body) if body else null

func highlight():
	# ray.force_raycast_update() -- do not using this, because we'll call this during _physics_process
	if ray.is_colliding():
		var body = ray.get_collider()
		if body == player_node:
			switch_highlight(null)
		else:
			switch_highlight(body)
	else:
		switch_highlight(null)