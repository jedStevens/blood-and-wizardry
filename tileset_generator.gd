tool
extends Node2D

# member variables here, example:
# var a=2
# var b="textvar"

export var width = 1 setget set_width
export var height = 1 setget set_height
export(Texture) var texture = null setget set_texture
export(String, "GENERATE", "CLEAR") var mode = "CLEAR" setget set_mode

func set_mode(new_mode):
	mode = new_mode
	if new_mode == "CLEAR":
		for child in get_children():
			remove_child(child)
	if new_mode == "GENERATE":
		generate()

func set_width(w):
	width = w
	
func set_height(h):
	height = h

func set_texture(t):
	texture = t

func generate():
	if (!get_tree().is_editor_hint()):
		var t_w = texture.get_width() / width
		var t_h = texture.get_height() / height
		var shape = RectangleShape2D.new()
		shape.set_extents(Vector2(t_w,t_h))
		for y in range(height):
			for x in range(width):
				var c = CollisionShape2D.new()
				c.set_shape(shape)
				
				var b = StaticBody2D.new()
				b.add_child(c)
				
				var s = Sprite.new()
				s.add_child(b)
				s.set_texture(texture)
				s.set_region(true)
				s.set_region_rect(Rect2(x*t_w,y*t_h,t_w,t_w))
				add_child(s,true)