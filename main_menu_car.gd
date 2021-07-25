extends AnimatedSprite

signal anim_done

var state = "follow"


func do_final_anim():
	state = "leave"

func _process(delta):
	match state:
		"follow":
			var m_point = get_global_mouse_position()
			var dir_vector = m_point - get_global_transform().origin
			
			look_at(m_point)
			if dir_vector.length() > 10:
				transform.origin += delta * dir_vector.normalized() * 650
		
		"leave":
			rotation = 0
			var edge = get_viewport().size.x
			if transform.origin.x > edge:
				state = "wipe"
				$".".scale = $".".scale * 10
				transform.origin.x = -450
				transform.origin.y = 140
			else:
				transform.origin.x += delta * 1200
		
		"wipe":
			var edge = get_viewport().size.x
			if transform.origin.x > edge + 650:
				state = "follow"
				$".".scale = $".".scale / 10
				emit_signal("anim_done")
			else:
				transform.origin.x += delta * 2200
		
