# Base Character Movement
extends KinematicBody2D

const decay = 0.9
const gravity = 900
const max_x_speed = 1200
const inertia_threshold = 125

var velocity = Vector2(0,0)

export var move_speed = 200  # max horizontal move speed in pixles per second
export var move_accel = 75
export var jump_height = 250 # in units
export var wall_jump_speed = 350

export var player_index = 1

export var jump_dot_threshold = 0.8
export var wall_jump_dot_threshold = 0.8

export var wall_jump_vector = Vector2(100,-1)

var n
var can_jump = false
var jump_attempt = false

func _ready():
	set_process(true)
	set_process_input(true)

func _input(event):
	pass


func _process(delta):
	
	velocity.x *= decay
	
	
	var moving = false
	var falling = false
	
	if (!is_colliding() and velocity.y > -inertia_threshold):
		velocity.y += gravity * delta
	
	if velocity.y < -inertia_threshold:
		velocity.y *= decay
	
	
	var too_fast = abs(velocity.x) > max_x_speed
	if (not too_fast):
		if (Input.is_action_pressed("player_"+str(player_index)+"_left")):
			velocity.x -= move_accel
			moving = true
		if (Input.is_action_pressed("player_"+str(player_index)+"_right")):
			velocity.x += move_accel
			moving = true
		
		if abs(velocity.x) > move_speed:
			velocity.x = sign(velocity.x) * move_speed
	
	var motion = velocity * delta
	motion = move(motion)
	
	if (is_colliding()):
		can_jump = true
		n = get_collision_normal()
		motion = n.slide(motion)
		velocity = n.slide(velocity)
		move(motion)
		
		if (Input.is_action_pressed("player_"+str(player_index)+"_jump") and n.normalized().dot(Vector2(0,-1)) > jump_dot_threshold):
			jump(n)
			
	if (can_jump and Input.is_action_pressed("player_"+str(player_index)+"_jump") and (n.normalized().dot(Vector2(1,0)) > wall_jump_dot_threshold or n.normalized().dot(Vector2(-1,0)) > wall_jump_dot_threshold)):
		can_jump = false
		wall_jump(n)

func jump(normal):
	velocity.y = -jump_height

func wall_jump(normal):
	velocity.x = sign(normal.x) * wall_jump_vector.x * wall_jump_speed
	velocity.y = wall_jump_vector.y * wall_jump_speed


