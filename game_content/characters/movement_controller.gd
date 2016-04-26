# Base Character Movement

extends KinematicBody2D

const ALPHA = 0.1
const EPSILON = 0.0005
const SCALE_FACTOR = 25
const STATE_EXPIRATION_TIME = 1.0 / 20.0

var host = true
var packet_peer = null

var state = null
var state_timer = 0

var velocity = Vector2(0,0)

var id = 0

func _ready():
	set_process(true)
	id = 0 #Globals.get("next_player_id")
	Globals.set("next_player_id", id+1)
# Integrate Forces

# Input

func broadcast(packet):
	if (host):
		pass
		# BROADCAST PACKET TO GAME SCRIPT
	else:
		packet_peer.put_var(packet)

func set_state(state):
	self.state = state
	self.state_timer = 0
	
	set_pos(state[0])
	velocity = state[1]

func lerp_pos(v1,v2,alpha):
	return v1 * alpha + v2 * (1.0 - alpha)

func slerp_pos(r1, r2, alpha):
	var v1 = Vector2(cos(r1), sin(r1))
	var v2 = Vector2(cos(r2), sin(r2))
	var v = slerp(v1, v2, alpha)
	return atan2(v.y,v.x)

func _process(delta):
	
	velocity *= 0.8
	
	if (!is_colliding()):
		velocity.y += 40
	
	if (Input.is_action_pressed("ui_left")):
		velocity.x -= 40
	if (Input.is_action_pressed("ui_right")):
		velocity.x += 40
	
	if (is_colliding()):
		velocity = get_collision_normal().slide(velocity)
	
	move(velocity * delta)

func get_id():
	return id

func get_velocity():
	return velocity

func set_id(i):
	id = i