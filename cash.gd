extends AnimatedSprite

func _process(delta):
	modulate.a -= delta * 1.3
	if modulate.a <= 0:
		get_parent().remove_child(self)

func _on_cash_animation_finished():
	playing = false
	frame = 2
