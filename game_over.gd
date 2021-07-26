extends Node2D


func _ready():
	$RichTextLabel.text = "On stealing {total_gold_stolen} gold bars across {levels_won} heists, you earned yourself {prison_term} years of free room and board." \
		.format(get_tree().get_nodes_in_group("main")[0].final_stats)

func _on_Button_pressed():
	get_tree().get_nodes_in_group("main")[0].load_level("main_menu", false)

