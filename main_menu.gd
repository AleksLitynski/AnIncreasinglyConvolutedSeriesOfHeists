extends Node2D

func anim_done():
	var main = get_tree().get_nodes_in_group("main")[0]
	main.load_level(main.level_sequence[0])

func _on_play_mouse_entered():
	$splash_idle.texture = preload("res://sprites/splash_play.png")

func _on_play_mouse_exited():
	$splash_idle.texture = preload("res://sprites/splash_idle.png")

func _on_help_mouse_entered():
	$splash_idle.texture = preload("res://sprites/splash_help.png")

func _on_help_mouse_exited():
	$splash_idle.texture = preload("res://sprites/splash_idle.png")

var clicked = false
func _on_play_pressed():
	if !clicked:
		clicked = true
		$Car.connect("anim_done", self, "anim_done")
		$Car.do_final_anim()

func _on_help_pressed():
	get_tree().get_nodes_in_group("main")[0].load_level("help", false)
