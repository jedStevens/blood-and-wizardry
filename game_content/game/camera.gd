
extends Camera2D

# member variables here, example:
# var a=2
# var b="textvar"

func _ready():
	set_fixed_process(true)

func _fixed_process(delta):
	var avg = Vector2(0,0)
	var i = 0
	for player in get_tree().get_nodes_in_group("players"):
		avg += player.get_pos()
		i += 1
	avg = avg / i
	set_pos(avg)