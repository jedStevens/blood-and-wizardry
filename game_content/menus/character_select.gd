
extends CenterContainer

# member variables here, example:
# var a=2
# var b="textvar"

var icon_positions = []

var players = [0,1]
var players_accepted = [true, true]

var selected_blend_state = BLEND_MODE_SUB

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	var icons = get_node("vert-Box/cent-Box/icons").get_children()
	var maxX = 0
	for icon in icons:
		icon_positions.append(icon.get_rect().pos)
		if icon.get_rect().pos.x > maxX:
			maxX = icon.get_rect().pos.x
	
	# Adjust positions for icon size (64) and center it on screen
	for i in range(icon_positions.size()):
		icon_positions[i].x -= maxX /2
		icon_positions[i].y += 64
	
	set_fixed_process(true)
	set_process_input(true)

func _fixed_process(delta):
	players[0] = clamp(players[0] ,0 , icon_positions.size()-1)
	players[1] = clamp(players[1] ,0 , icon_positions.size()-1)
	get_node("P1").set_pos(icon_positions[players[0]] + get_rect().size / 2 + Vector2(-24*int(players_accepted[0]),0))
	get_node("P2").set_pos(icon_positions[players[1]] + get_rect().size / 2 + Vector2(-24*int(players_accepted[1]),24))


func _input(event):
	# UI NAVIGATION
	if event.is_echo() == false:
		if !players_accepted[0]:
			if (Input.is_action_pressed("p1_ui_left")):
				players[0] -= 1
			if (Input.is_action_pressed("p1_ui_right")):
				players[0] += 1
		if (Input.is_action_pressed("p1_ui_accept")):
			players_accepted[0] = !players_accepted[0]
		
		if !players_accepted[1]:
			if (Input.is_action_pressed("p2_ui_left")):
				players[1] -= 1
			if (Input.is_action_pressed("p2_ui_right")):
				players[1] += 1
		if (Input.is_action_pressed("p2_ui_accept")):
			players_accepted[1] = true
		if (Input.is_action_pressed("p2_ui_back")):
			players_accepted[1] = !players_accepted[1]
		
		if all(players_accepted) and Input.is_action_pressed("p1_ui_start"):
			get_tree().change_scene("res://game/stage1.scn")
			Globals.set("players", players)

func all(l):
	for x in l:
		if x == false:
			return false
	return true