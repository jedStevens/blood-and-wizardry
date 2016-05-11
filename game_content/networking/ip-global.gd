
extends Label

# member variables here, example:
# var a=2
# var b="textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_fixed_process(true)

func _fixed_process(delta):
	var ip = Globals.get("ip")
	var port =  Globals.get("port")
	var is_host = Globals.get("host")
	var client_count = 0
	if is_host:
		client_count = get_node("..").clients.size()
	set_text("IP: " + str(ip) + " : " + str(port) + "\nHost: "+ str(is_host) + "\nClient Count:" + str(client_count))