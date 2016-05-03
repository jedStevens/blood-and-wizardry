extends CenterContainer

# member variables here, example:
# var a=2
# var b="textvar"

var players = [0]

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_process_input(true)
	var icons = get_icons("res://game_content/characters")
	for icon in icons:
		var sprite = Sprite.new()
		sprite.set_texture(load(icon))
		get_node("layout/icons").add_child(sprite)
	print("Icons: ", icons)
	print("Children: ", get_node("layout/icons").get_child_count())
func run_game():
	pass

func get_icons(path):
	var icons = []
	var d = Directory.new()
	if d.open( path )==0:
		d.list_dir_begin()
		var file_name = d.get_next()
		while(file_name!=""):
			if d.current_is_dir() and file_name != "." and file_name != ".." :
				icons.append(path + "/" + file_name + "/icon.png")
			file_name = d.get_next()
	else:
		print("Some open Error, maybe directory not found?")
	return icons