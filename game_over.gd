extends Node2D


func _ready():
	$RichTextLabel.text = "For stealing {total_gold_stolen} gold bars across {levels_won} heists, you have earned yourself {prison_term} years in prison." \
		.format(get_tree().get_nodes_in_group("main")[0].final_stats)

func _on_Button_pressed():
	get_tree().get_nodes_in_group("main")[0].load_level("main_menu", false)
