
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

func spawn(character_id, next_id):
	
	# NOTE ON THIS FUNCTION
	# SHOULD ONLY BE TRUSTED TO RUN ON HOST
	
	var character = load(CHARACTER_MAP[character_id]).instance()
	
	# Add rules for spawning here
	# Right now just use random pos on screen
	
	var pos = Vector2(0,0)
	
	character.set_pos(pos)
	print("Spawning with next_id as: ", next_id)
	character.set_id(next_id)
	
	add_child(character)
	
	return [character_id, next_id, pos, Vector2(0,0)]

func get_by_id(id):
	for player in get_children():
		if player.get_id() == id:
			return player
	return null