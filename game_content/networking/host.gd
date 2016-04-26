extends Node


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

var timer = 0

var network_fps = 40 # MAGIC NUMBER
var port = null
var ip = null

var packet_peer = null

var clients = []


func _ready():
	packet_peer = PacketPeerUDP.new()
	
	set_process(true)
	
	start_server()
	
	# GIVE PLAYERS A REFERENCE TO THE PACKET PEER FOR INPUT EVENTS
	
	print("Host has started")

func start_server():
	# Set Vars via the globals set in the character select
	port = Globals.get("port")
	ip = Globals.get("ip")
	print ("Starting server on: ", ip," : ", port)
	if (packet_peer.listen(port) != OK):
		print("Error listening on port ", port.get_value())
		return
	else:
		print("Listening on port: ", port)
		set_host_players(true)

func stop_server():
	packet_peer.close()
	print("Stopped listening on ", port)

func broadcast(packet):
	for client in clients:
		packet_peer.set_send_address(client.ip, client.port)
		packet_peer.put_var(packet)

# Handle the events from 'packet'
# Currently missing
func handle_event(packet):
	pass
	
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

func _process(delta):
	
	#
	# Handle Incoming Packets
	#
	
	while (packet_peer.get_available_packet_count() > 0):
		var packet = packet_peer.get_var()
		
		if (packet == null):
			continue
		
		var packet_ip = packet_peer.get_packet_ip()
		var packet_port = packet_peer.get_packet_port()
		
		var spawns = []
		
		if (packet[0] == "connect"):
			print("Connect Request")
			if (not has_client(packet_ip, packet_port)):
				for i in range(packet[1].size()):
					spawns.append(get_node("players").spawn(packet[1][i]))
				print ("Client connected from ", packet_ip, ":", packet_port)
				clients.append({ip = packet_ip, port = packet_port, seq = 0, players = packet[1]})
			
			packet_peer.set_send_address(packet_ip, packet_port)
			
			packet_peer.put_var(["accepted", spawns])
		
		elif (packet[0] == "disconnect"):
			packet_peer.close()
		
		elif (packet[0] == "event"):
			handle_event(packet)
			
			# Broadcast event to clients
			for client in clients:
				if (client.ip != packet_ip and client.port != packet_port):
					packet_peer.set_send_address(packet_ip, packet_port)
					packet_peer.put_var(packet)
	
	
	#
	# Send outgoing packets
	#
	
	var duration = 1.0 / network_fps
	
	# Ensure that packets are sent 'network_fps' times per second
	if (timer < duration):
		timer += delta
	else:
		timer = 0
		for client in clients:
			var packet = ["update", client.seq]
			client.seq += 1
			for player in get_node("players").get_children():
				packet.append([player.get_id(), player.get_pos(), player.get_velocity()])
				
				
			packet_peer.set_send_address(client.ip, client.port)
			packet_peer.put_var(packet)
