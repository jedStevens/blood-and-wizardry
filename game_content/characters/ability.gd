extends Node

export var cast_time = 0.5
export var cooldown_time = 1.0


func run(message=null):
	print("Used Ability: ", message)
	cast()

func cast(target=null):
	pass # Wait out cast duration, play cast animation

func apply(target=null):
	pass # Activate the ability, ie give target some heal, create an arbitrary projectile

func cancel():
	pass # stop using this ability, ie other player stunned this one, this player hit the stop key