extends Spatial

onready var player_main = get_node("Female_palladium/AnimationPlayer")
#onready var player_shocker = get_node("shocker/shock_stick_armature/AnimationPlayer")

var is_action = false
var is_walking = false
var is_sprinting = false

func _ready():
	player_main.play("female_rest_99")
	player_main.connect("animation_finished", self, "_on_female_anim_finished")

func _on_female_anim_finished(anim_name):
	is_action = false
	if is_walking:
		if is_sprinting:
			player_main.play("female_walk_2")
		else:
			player_main.play("female_walk_2")
	else:
		player_main.play("female_rest_99")

func walk(sprint):
	if is_action:
		return
	if not is_sprinting and sprint:
		player_main.play("female_walk_2")
	elif not is_walking:
		player_main.play("female_walk_2")
	is_walking = true
	is_sprinting = sprint

func stop():
	if is_action:
		return
	if is_walking:
		player_main.play("female_rest_99")
	is_walking = false
	is_sprinting = false

func action():
#	if not is_action:
#		player_main.play("vasya_grabs_shocker")
#		player_shocker.play("shock_stick_grab")
	is_action = true

func _physics_process(delta):
#	if Input.is_action_pressed("weapon_1"):
#		action()
#		return
	
	var sprinting = false #Input.is_action_pressed("movement_sprint")
	
	if Input.is_action_pressed("movement_forward"):
		walk(sprinting)
	elif Input.is_action_pressed("movement_backward"):
		walk(sprinting)
	elif Input.is_action_pressed("movement_left"):
		walk(sprinting)
	elif Input.is_action_pressed("movement_right"):
		walk(sprinting)
	else:
		stop()