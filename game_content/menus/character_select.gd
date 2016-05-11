extends CenterContainer

# member variables here, example:
# var a=2
# var b="textvar"

var players = [0,1,null,null]
var confirmed = [false,true,false,false]

var icon_anchor = Vector2(0,0)

func all_ready():
	for i in range(players.size()):
		if players[i] == null:
			break
		if !confirmed[i]:
			return false
	return true

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_process_input(true)
	set_fixed_process(true)

func _input(event):

	if Input.is_action_pressed("ui_left") and !confirmed[event.device]:
		players[event.device] -= 1
	if Input.is_action_pressed("ui_right") and !confirmed[event.device]:
		players[event.device] += 1
	
	if (all_ready() and Input.is_action_pressed("ui_accept") and event.is_pressed()):
		run_game()
	elif Input.is_action_pressed("ui_accept"):
		confirmed[event.device] = !confirmed[event.device]
	
	if Input.is_action_pressed("ui_cancel"):
		confirmed[event.device] = false

func _fixed_process(delta):
	for i in range(players.size()):
		if players[i] != null:
			players[i] %= (get_node("layout/icons").get_child_count())
			if players[i] < 0:
				players[i] = get_node("layout/icons").get_child_count() - 1
			var p = get_node("layout/icons").get_child(players[i]).get_pos()
			
			get_node("layout/player-markers/p"+str(i+1)).set_hidden(false)
			get_node("layout/player-markers/p"+str(i+1)).set_pos(p)
		else:
			get_node("layout/player-markers/p"+str(i+1)).set_hidden(true)
	
	get_node("play-label").set_hidden(!all_ready())

func run_game():
	Globals.set("players", players)
	get_tree().change_scene("res://game_content/game/test-mode.scn")