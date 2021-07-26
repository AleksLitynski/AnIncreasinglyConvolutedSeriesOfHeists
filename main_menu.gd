extends Node2D

func anim_done():
	var main = get_tree().get_nodes_in_group("main")[0]
	main.load_level(starting_level)

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


var level_ids = {}
var starting_level = null
func _ready():
	var main = get_tree().get_nodes_in_group("main")[0]
	for level in main.level_sequence:
		var lvl_name = load("res://levels/%s.tscn" % level).instance().level_name
		level_ids[lvl_name] = level
		$starting_level.add_item(lvl_name)
	$starting_level.add_item("Random")
	starting_level = main.level_sequence[0]
	randomize()

func _on_randomize_toggled(button_pressed):
	get_tree().get_nodes_in_group("main")[0].randomize_level = button_pressed

func _on_starting_level_item_selected(index):
	var lvl_name = $starting_level.get_item_text(index)
	if lvl_name == "Random":
		var vals = level_ids.values()
		starting_level = vals[randi() % vals.size()]
	else:
		starting_level = level_ids[lvl_name]


func _on_credits_pressed():
	get_tree().get_nodes_in_group("main")[0].load_level("credits", false)
