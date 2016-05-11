extends "../movement_controller.gd"

const Smash = preload("smash.gd")

func _ready():
	abilities[0] = get_node("smash-shape")