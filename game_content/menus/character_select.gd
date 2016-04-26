extends CenterContainer

# member variables here, example:
# var a=2
# var b="textvar"

var players = [0]

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_process_input(true)

func on_host_pressed():
	Globals.set("client", false)
	Globals.set("host", true)
	Globals.set("port", get_node("layout/controls/port").get_val())
	Globals.set("ip", get_node("layout/controls/ip").get_text())
	
	run_game()

func on_client_pressed():
	Globals.set("client", true)
	Globals.set("host", false)
	Globals.set("port", get_node("layout/controls/port").get_val())
	Globals.set("ip", get_node("layout/controls/ip").get_text())
	
	run_game()

func run_game():
	Globals.set("players", players)
	Globals.set("network_fps", 60)
	get_tree().change_scene("res://game_content/game/stage1.scn")