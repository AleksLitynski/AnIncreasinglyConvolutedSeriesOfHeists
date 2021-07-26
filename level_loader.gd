extends Node2D

func _ready():
	$Button.connect("pressed", self, "pressed")
	$Score.bbcode_text = "Heists Completed: [u]" + str(get_tree().get_nodes_in_group("main")[0].levels_won) + "[/u]"
	$Score.bbcode_text += "Total Gold Stolen: [u]" + str(get_tree().get_nodes_in_group("main")[0].total_gold_stolen) + "[/u]"

var state = "enter" # enter, exit
var level = null
func _process(delta):
	match state:
		"enter":
			if $Car.transform.origin.x < 260:
				$Car.transform.origin.x += delta * 1200
		"exit":
			if $Car.transform.origin.x < get_viewport().size.x + 600:
				$Car.transform.origin.x += delta * 1400
			else:
				swap_to_level()

func load_level(lvl):
	level = lvl
	if "level_name" in level:
		$Target_Text.bbcode_text += "\n\n[u]" + level.level_name + "[/u]"
	
	if "level_description" in level:
		$Target_Text.bbcode_text += "\n" + level.level_description

func pressed():
	get_tree().get_nodes_in_group("main")[0].get_node("VroomSound").play()
	state = "exit"

func swap_to_level():
	get_parent().add_child(level)
	get_parent().remove_child(self)
	
