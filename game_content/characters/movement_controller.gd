# Base Character Movement
extends KinematicBody2D

const decay = 0.9
const gravity = 900
const max_x_speed = 1200
const inertia_threshold = 125
const max_ability_count_per_mode = 3
const max_ability_mode_count = 2

const Ability = preload("ability.gd")

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
var moving = false


var abilities = []
var ability_mode = 0
var ability_offset = 3

var disable_timer = null
var disabled = false

func _ready():
	set_process(true)
	set_process_input(true)
	
	for i in range(max_ability_count_per_mode * max_ability_mode_count):
		abilities.append(Ability.new())
	
	disable_timer = get_node("disable-timer")
	disable_timer.connect("timeout",self, "_enable")

func _input(event):
	if (event.type == InputEvent.KEY or event.type == InputEvent.JOYSTICK_BUTTON)  and !event.is_echo() and event.is_pressed():
		
		if (can_jump and Input.is_action_pressed("player_"+str(player_index)+"_jump") and n.normalized().dot(Vector2(0,-1)) > jump_dot_threshold):
			can_jump = false
			jump(n)
			
		elif (can_jump and Input.is_action_pressed("player_"+str(player_index)+"_jump") and (n.normalized().dot(Vector2(1,0)) > wall_jump_dot_threshold or n.normalized().dot(Vector2(-1,0)) > wall_jump_dot_threshold)):
			can_jump = false
			wall_jump(n)
		
		if (Input.is_action_pressed("player_"+str(player_index)+"_mode_switch")):
			ability_mode += 1
			ability_mode = ability_mode % max_ability_mode_count
		
		for i in range(max_ability_count_per_mode):
			if (Input.is_action_pressed("player_"+str(player_index)+"_ability_"+str(i+1))):
				abilities[i + (ability_mode * ability_offset)].run(i + (ability_mode * ability_offset))
		

func _process(delta):
	if not disabled:
		velocity.x *= decay
		var falling = false
		
		if (!is_colliding() and velocity.y > -inertia_threshold):
			velocity.y += gravity * delta
		
		if velocity.y < -inertia_threshold:
			velocity.y *= decay
		
		if (Input.is_action_pressed("player_"+str(player_index)+"_left")):
			velocity.x -= move_accel
			moving = true
			if (!is_colliding()): can_jump = false
		
		if (Input.is_action_pressed("player_"+str(player_index)+"_right")):
			velocity.x += move_accel
			moving = true
			if (!is_colliding()): can_jump = false
		
		
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
		
		var dir = get_scale()
		if sign(velocity.x) > 0:
			dir.x = 1
		elif sign(velocity.x) < 0:
			dir.x = -1
		set_scale(dir)

func jump(normal):
	velocity.y = -jump_height

func wall_jump(normal):
	velocity.x = sign(normal.x) * wall_jump_vector.x * wall_jump_speed
	velocity.y = wall_jump_vector.y * wall_jump_speed

func disable(duration):
	if not disabled:
		disabled = true
		
		disable_timer.set_wait_time(duration)
		disable_timer.set_one_shot(true)
		disable_timer.start()
		print ("Disabling: ", duration)

func _enable():
	print("enabling")
	disabled = false