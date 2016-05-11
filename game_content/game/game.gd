extends Node

const CONNECT_ATTEMPTS = 20

var timer = 0
var host = true
var ready = false
var start = null
var connect = null
var network_fps = null
var port = null
var ip = null
# Set these as globals in the char select

var packet_peer = null

# For server
var clients = []

# For client
var seq = -1
var state = {}

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	
	print("Starting game scene")
	
	packet_peer = PacketPeerUDP.new()
	
	set_process(true)
	
	if (Globals.get("host")):
		start_server()
	
	elif (Globals.get("client")):
		print("Client set in globals")
		start_client()
	
	var spawns = []
	var players = Globals.get("players")
	if players != null:
		for i in players:
			spawns.append(get_node("players").spawn(i))
		print("Spawns: ",spawns)

func _process(delta):
	# Server update
	if (Globals.get("host")):
		
		# Handle Incoming Packets
		while (packet_peer.get_available_packet_count() > 0):
			var packet = packet_peer.get_var()
			
			if (packet == null):
				continue
			
			var packet_ip = packet_peer.get_packet_ip()
			var packet_port = packet_peer.get_packet_port()
			
			var spawns = []
			
			if (packet[0] == "connect"):
				print("Connect Request")
				if ( not has_client(packet_ip, packet_port)):
					print ("Client connected from ", packet_ip, ":", packet_port)
					clients.append({ip = packet_ip, port = packet_port, seq = 0, players = packet[1]})
					for i in range(packet[1].size()):
						spawns.append(get_node("players").spawn(packet[1][i]))
				
				packet_peer.set_send_address(packet_ip, packet_port)
				
				packet_peer.put_var(["accepted", spawns])
			
			elif (packet[0] == "disconnect"):
				if (Globals.get("host")):
					packet_peer.close()
				
				elif (Globals.get("client")):
					packet_peer.close()
			
			elif (packet[0] == "event"):
				# Handle locally
				handle_event(packet)
				
				# Broadcast event to clients
				for client in clients:
					if (client.ip != packet_ip and client.port != packet_port):
						packet_peer.set_send_address(packet_ip, packet_port)
						packet_peer.put_var(packet)
		
		# Send outgoing packets
		var duration = 1.0 / Globals.get("network_fps")
		
		if (timer < duration):
			timer += delta
		else:
			timer = 0
			for client in clients:
				var packet = ["update", client.seq]
				client.seq += 1
				for player in get_node("players").get_children():
					packet.append([player.get_id(), player.get_pos(), player.get_velocity()])
					
					"""
					PACKET FORMAT
					
					0 - id, player id, used for matching players from other machines
					1 - pos, position of the player
					2 - velocity, the direction as a unit vector multiplied by a speed scalar
					3 - ? State? idk 
					
					"""
					
				packet_peer.set_send_address(client.ip, client.port)
				packet_peer.put_var(packet)
	
	# Client Update
	elif (Globals.get("client")):
		while (packet_peer.get_available_packet_count() > 0):
			var packet = packet_peer.get_var()
			
			if (packet == null):
				continue
			
			if (packet[0] == "update"):
				handle_update(packet)
			elif (packet[0] == "event"):
				handle_event(packet)

func start_client():
	var client_port = Globals.get("port") + 1
	
	while (packet_peer.listen(client_port) != OK):
		client_port += 1
	
	# Set server address
	var res = packet_peer.set_send_address(Globals.get("ip"), client_port)
	
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
				
				#for i in range(packet[1].size()):
				#	var character = get_node("players").get_character(packet[1][i])
				#	add_child(character)
				
				break
	
	if (not connected):
		print("Error connecting to ", Globals.get("ip"), ":", client_port)
		return
	else:
		print("Connected to ", Globals.get("ip"), ":", Globals.get("port"))
		
		set_host_players(false)

func stop_client():
	
	packet_peer.close()
	set_host_players(true)
	print("Disconnected from ", Globals.get("ip"), ":", Globals.get("port"))

func start_server():
	if (packet_peer.listen(Globals.get("port")) != OK):
		print("Listening on port: ", Globals.get("port"))
		set_host_players(true)

func stop_server():
	packet_peer.close()
	print("Stopped listening on ", Globals.get("port"))

func broadcast(packet):
	for client in clients:
		packet_peer.set_send_address(client.ip, client.port)
		packet_peer.put_var(packet)

func handle_update(packet):
	if (packet[1] > seq):
		seq = packet[1]
		for i in range(2, packet.size()-1):
			# Decompose packet
			var id = packet[i][0]
			var pos = packet[i][1]
			var vel = packet[i][2]
			
			var player = null
			for p in get_node("players").get_children():
				if p.get_id() == id:
					player = p
			
			if player == null:
				print("Bad update packet, player at id does not exist, id=", id)
			
			player.set_state([pos, vel])

# Handle the events from 'packet'
# Currently missing
func handle_event(packet):
	pass

# Turn on/off the hosting of the players depending on the current state of the server
func set_host_players(host):
	for player in get_node("players").get_children():
		player.host = host

# Set each player's packet peer to this one
func set_packet_peer_players(packet_peer):
	for player in get_node("players").get_children():
		player.packet_peer = packet_peer

# Check if client is registered
func has_client(ip, port):
	for client in clients:
		if (client.ip == ip and client.port == port):
			return true
	return false