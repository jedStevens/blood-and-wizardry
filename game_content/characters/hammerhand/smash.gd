
extends "../ability.gd"

export var air_hang_duration = 0.2
export var dive_speed = 1000

var air_hang_timer = null

func _ready():
	pass

func cast():
	if get_node("..").is_colliding():
		get_node("../ability-player").play("smash")
	else:
		get_node("..").disable(air_hang_duration)
		dive()

func dive():
	var dir = Vector2(Input.get_joy_axis(get_node("..").player_index - 1, 0), Input.get_joy_axis(get_node("..").player_index - 1, 1))
	print ("Diving in: ",dir.normalized())
	get_node("..").velocity = dir * dive_speed