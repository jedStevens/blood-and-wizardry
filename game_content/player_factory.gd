
extends Node

# member variables here, example:
# var a=2
# var b="textvar"

var CHARACTER_MAP = [ "res://game_content/characters/hammerhand/hammerhand.scn" ]

func add_player(p):
	var char = load(CHARACTER_MAP[p]).instance()
	add_child(char)

func get_character(p):
	var char = load(CHARACTER_MAP[p]).instance()
	return char

func remove_player(id):
	pass

func spawn(character_id):
	var character = load(CHARACTER_MAP[character_id]).instance()
	
	# Add rules for spawning here
	# Right now just use random pos on screen
	
	var pos = Vector2(0,0)
	var id = Globals.get("next_player_id")
	if id == null:
		id = 0
	Globals.set("next_player_id", id+1)
	
	character.set_pos(pos)
	character.set_id(id)
	
	add_child(character)
	
	return [id, pos, Vector2(0,0)]