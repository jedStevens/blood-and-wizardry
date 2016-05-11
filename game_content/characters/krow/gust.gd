
extends "../ability.gd"

export var damage = 25

func cast(trigger = null):
	if not get_node("..").frozen and not get_node("..").disabled:
		get_node("..").disable(get_node("../animator").get_animation("gust").get_length())
		get_node("../animator").play("gust")


func _on_gust_body_enter_shape( body_id, body, body_shape, area_shape ):
	print ("Collision: ", body.get_name())
	body.health -= damage
