
extends CenterContainer

# member variables here, example:
# var a=2
# var b="textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_process(true)

func _process(delta):
	if (Input.is_action_pressed("ui_accept")):
		coop_start()

func coop_start():
	get_tree().change_scene("res://game_content/menus/character_select_local.scn")
