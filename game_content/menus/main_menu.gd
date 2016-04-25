
extends CenterContainer

# member variables here, example:
# var a=2
# var b="textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass


func _on_Play_Game_pressed():
	get_tree().change_scene("res://menus/character_select.scn")
