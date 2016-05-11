
extends "../movement_controller.gd"

# member variables here, example:
# var a=2
# var b="textvar"

var stamina = 0
export var max_stamina = 10

export var dash_distance = 500
export var stamina_regen_rate = 2

export var flap_height = 400

func _ready():
	stamina = max_stamina
	get_node("stamina-bar").set_max(max_stamina)
	abilities[0] = get_node("dash")
	abilities[1] = get_node("gust")

func derived_ai(delta):
	if on_floor():
		stamina += stamina_regen_rate*delta
		if stamina > max_stamina:
			stamina = max_stamina
	
	get_node("stamina-bar").set_value(stamina)

func jump(normal):
	if (on_floor()):
		velocity.y = -jump_height
	elif (stamina >= 1):
		stamina -= 1
		velocity.y = -flap_height