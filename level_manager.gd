extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	# load_level("main_menu", false)
	load_level("level_2", false)

var current_level = null
var stats = null
var level_running = false
var levels_won = 0
var level_sequence = [
	"level_1",
	"level_2",
]

func goto_next_level():
	var c_lvl_idx = level_sequence.find(current_level.level_id)
	var n_lvl_idx = c_lvl_idx + 1
	if c_lvl_idx == -1 or n_lvl_idx >= len(level_sequence):
		load_level(level_sequence[0])
		return
	load_level(level_sequence[n_lvl_idx])

func clear_text():
	var overlays = get_tree().get_nodes_in_group("overlay_text")
	if len(overlays) > 0:
		var text = overlays[0]
		text.text = ""

func render_stats():
	var text = get_tree().get_nodes_in_group("overlay_text")[0]
	text.text = "Gold: {gold}/{max_gold}\nTime: {time}".format({
		"gold": stats["gold"],
		"max_gold": stats["max_gold"],
		"time": round(stats["time"])
	})

func load_level(name, use_loader = true):
	level_running = false

	# delete old level
	if current_level:
		remove_child(current_level)

	# load new level
	current_level = load("res://levels/%s.tscn" % name).instance()

	# use the loader if needed
	if use_loader:
		var loader = preload("res://level_loader.tscn").instance()
		loader.load_level(current_level)
		add_child(loader)
	else:
		add_child(current_level)

func _process(delta):
	if stats:
		stats["time"] -= delta
		render_stats()
		if stats["time"] <= 0:
			lose_level()
			return
		if stats["gold"] == stats["max_gold"]:
			win_level()
			return
	else:
		clear_text()

func add_gold():
	if stats:
		stats["gold"] += 1

func start_level():
	stats = {
		"gold": 0,
		"max_gold": len(get_tree().get_nodes_in_group("gold")),
		"time": 60
	}

func lose_level():
	# show jail bars
	# go to lose screen
	print("lost level")
	levels_won = 0
	stats = null

func win_level():
	levels_won += 1
	current_level.win_level()
	stats = null
