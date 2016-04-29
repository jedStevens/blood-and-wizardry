# Base Character Movement

extends KinematicBody2D

const decay = 0.8
const gravity = 900

var velocity = Vector2(0,0)

export var move_speed = 200  # max horizontal move speed in pixles per second
export var move_accel = 75
export var jump_height = 250 # in units
export var wall_jump_speed = 350

export var player_index = 1



func _ready():
	set_process(true)
	set_process_input(true)

func _input(event):
	pass


func _process(delta):
	
	var moving = false
	if (!is_colliding()):
		velocity.y += gravity * delta
	
	
	if (Input.is_action_pressed("player_"+str(player_index)+"_left")):
		velocity.x -= move_accel
		moving = true
	if (Input.is_action_pressed("player_"+str(player_index)+"_right")):
		velocity.x += move_accel
		moving = true
	
	if !moving:
		velocity.x *= decay
	
	if abs(velocity.x) > move_speed:
		velocity.x = sign(velocity.x) * move_speed
	
	var motion = velocity * delta
	motion = move(motion)
	
	if (is_colliding()):
        var n = get_collision_normal()
        motion = n.slide(motion)
        velocity = n.slide(velocity)
        move(motion)