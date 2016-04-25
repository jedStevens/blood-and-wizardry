
extends Node2D

# member variables here, example:
# var a=2
# var b="textvar"

var CHARACTER_MAP = [ "res://characters/blood-boy/blood-boy.scn",
"res://characters/dark-bird/dark-bird.scn",
"res://characters/demon_woman/demon_woman.scn",
"res://characters/time_lord/time_lord.scn",
"res://characters/wind_walker/wind_walker.scn"]

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	for i in range(Globals.get("players").size()):
		var char = load(CHARACTER_MAP[i]).instance()
		add_child(char)

