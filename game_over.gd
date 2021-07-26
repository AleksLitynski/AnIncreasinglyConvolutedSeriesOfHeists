extends Node2D


func _ready():
	var f_stats = get_tree().get_nodes_in_group("main")[0].final_stats
	$RichTextLabel.text = "On stealing {total_gold_stolen} gold bars across {levels_won} heists, you earned yourself {prison_term} years of free room and board." \
		.format({
			"total_gold_stolen": f_stats["total_gold_stolen"],
			"levels_won": f_stats["levels_won"] + 1,
			"prison_term": f_stats["prison_term"],
		})

func _on_Button_pressed():
	get_tree().get_nodes_in_group("main")[0].load_level("main_menu", false)

