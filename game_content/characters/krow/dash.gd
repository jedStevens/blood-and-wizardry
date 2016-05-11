
extends "../ability.gd"

# member variables here, example:
# var a=2
# var b="textvar"

export var distance =  700
export var speed = 1000
export var stamina_cost = 3

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func cast(target=null):
	if (not get_node("../").frozen and get_node("../").stamina >= stamina_cost):
		var dir = Vector2(0,0)
		dir.x = Input.get_joy_axis(get_node("../").device_id(), 0)
		dir.y = Input.get_joy_axis(get_node("../").device_id(), 1)
		dir = dir.normalized()
		get_node("../").freeze(dir*speed, distance )
		get_node("../").stamina -= stamina_cost