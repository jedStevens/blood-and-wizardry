extends Node

const PlayerFactory = preload("res://game_content/player_factory.gd")
onready var playerFactory = PlayerFactory.new()

# PACKET FORMATS
# All the types of packets you may see and their format
# [0] is always a string of the type

# Client Connect Request Packet
# client -> host
# [0] = "connect"
# [1] = list of characters to add from client

# Host Accepted Connect Request Packet
# host -> client
# [0] = "accepted"
# [1] = spawn info
# note: spawn info is one of . . .
#                            an error, indicating that the characters requested couldn't be added
#                            or a list of spawns, spawn:[id, position]
#                                  *where each spawn's index is the player id on that client

# Client Disconnects From Host
# client -> host
# [0] = "disconnect"

# Host Disconnects
# host -> client
# [0] = "disconnect" <- I dont like how this is the same tag as an existing one but I can't think of a good word

# Update
# host -> client
# [0] = "update"
# [1] = list of update info, [id, pos, vel]

const CONNECT_ATTEMPTS = 20

var packet_peer = null

var seq = -1
var state = {}

var port = null
var ip = null
var network_fps = 40 # MAGIC NUMBER
var player_ids = []

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	packet_peer = PacketPeerUDP.new()
	
	set_process(true)
	
	start_client()
	
	# GIVE PLAYERS A REFERENCE TO THE PACKET PEER FOR INPUT EVENTS

func start_client():
	
	var client_port = Globals.get("port")
	
	while (packet_peer.listen(client_port) != OK):
		client_port += 1
	
	# Set server address
	packet_peer.set_send_address(Globals.get("ip"), Globals.get("port"))
	
	# Try to connect to server
	var attempts = 0
	var connected = false
	
	while (not connected and attempts < CONNECT_ATTEMPTS):
		print("attempting to connect to host")
		attempts += 1
		packet_peer.put_var(["connect", Globals.get("players")])
		OS.delay_msec(100)
		
		while (packet_peer.get_available_packet_count() > 0):
			var packet = packet_peer.get_var()
			print("Packet at 0: ", packet[0])
			if (packet != null and packet[0] == "accepted"):
				connected = true
				for spawn in packet[1]:
					print ("Character")
					var char = playerFactory.get_character(spawn[0])
					char.set_id(spawn[1])
					char.set_pos(spawn[2])
					char.set_velocity(spawn[3])
					get_node("players").add_child(char)
				break
	
	if (not connected):
		print("Error connecting to ", Globals.get("ip"), ":", Globals.get("port"))
		return
	else:
		print("Connected to ", Globals.get("ip"), ":", Globals.get("port"))
		port = client_port
		ip = Globals.get("ip")
		set_host_players(false)

func stop_client():
	packet_peer.close()
	set_host_players(true)
	print("Disconnected from ", Globals.get("ip"), ":", Globals.get("port"))

func _process(delta):
	while (packet_peer.get_available_packet_count() > 0):
		var packet = packet_peer.get_var()
		
		if (packet == null):
			continue
		
		if (packet[0] == "update"):
			handle_update(packet)
		elif (packet[0] == "event"):
			handle_event(packet)
		elif (packet[0] == "client_connected"):
			handle_connection(packet)
		elif (packet[0] == "response"):
			handle_response(packet)


func set_host_players(b):
	for player in get_node("players").get_children():
		player.host = b

func handle_update(packet):
	pass

func handle_event(packet):
	pass
	
func handle_response(packet):
	var player_index = 1
	for id in packet[1]:
		print("Controlling:",id)
		var character = get_player(id)
		if (character != null):
			get_player(id).controllable = true
			get_player(id).set_player_id(player_index)
			player_index += 1
		
func handle_connection(packet):
	for spawn in packet[1]:
		var player = get_player(spawn[1])
		if (player == false):
			var char = playerFactory.get_character(spawn[0])
			char.set_id(spawn[1])
			char.set_pos(spawn[2])
			char.set_velocity(spawn[3])
			get_node("players").add_child(char)
		else:
			player.set_pos(spawn[2])
			player.set_velocity(spawn[3])
		
func get_player(id):
	for player in get_node("players").get_children():
		print(player.get_id(), " == ", id, " ?")
		if player.get_id() == id:
			return player
	return null