extends Node2D

# Called when the node enters the scene tree for the first time.
var rand
func _ready():
	rand = RandomNumberGenerator.new()
	rand.randomize()
	# load_level("main_menu", false)
	load_level("level_2", false)
	play_next_song()

var current_level = null
var stats = null
var level_running = false
var levels_won = 0
var total_gold_stolen = 0
var final_stats = {
	"levels_won": 0,
	"total_gold_stolen": 0,
	"prison_term": 0,
}
var level_sequence = [
	"level_1",
	"level_2",
]

func play_next_song():
	[$Song_1, $Song_2, $Song_3, $Song_4][rand.randi_range(0, 3)].play()

func goto_next_level():
	var c_lvl_idx = level_sequence.find(current_level.level_id)
	var n_lvl_idx = c_lvl_idx + 1
	if c_lvl_idx == -1 or n_lvl_idx >= len(level_sequence):
		load_level(level_sequence[0])
		return
	load_level(level_sequence[n_lvl_idx])

func load_level(name, use_loader = true):
	level_running = false
	lose_state = null
	lose_wait = 1.5
	if bars:
		bars.queue_free()
		bars = null
	
	if name == "main_menu":
		final_stats = {
			"levels_won": 0,
			"total_gold_stolen": 0,
			"prison_term": 0,
		}

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
	match lose_state:
		"bars_up":
			if bars.transform.origin.y <= -147:
				lose_state = "door_close"
				bars.transform.origin.y = -147
			else:
				bars.transform.origin.y -= delta * 350
		"door_close":
			if bars.get_node("gameover_door").transform.origin.x >= 512:
				lose_state = "lose_anim_done"
				bars.get_node("gameover_door").transform.origin.x = 512
			else:
				bars.get_node("gameover_door").transform.origin.x += delta * 650
		"lose_anim_done":
			if lose_wait > 0:
				lose_wait -= delta
			else:
				$PrisonBarsSound.stop()
				load_level("game_over", false)


	if stats:
		stats["time"] -= delta
		if stats["time"] <= 0:
			lose_level()
			return
		if stats["gold"] == stats["max_gold"]:
			win_level()
			return

func add_gold():
	if stats:
		stats["gold"] += 1
		total_gold_stolen += 1
		if current_level.has_method("add_gold"):
			current_level.add_gold()

func start_level():
	stats = {
		"gold": 0,
		"max_gold": len(get_tree().get_nodes_in_group("gold")),
		"time": 60
	}
	
func calc_final_stats():
	final_stats["levels_won"] = levels_won
	final_stats["total_gold_stolen"] = total_gold_stolen
	final_stats["prison_term"] = (levels_won * 10) + (5 if stats["gold"] > 0 else 0)

var lose_state = null
var bars = null
var lose_wait = 1.5
func lose_level():
	$PrisonBarsSound.play()
	[$LoseSound_1, $LoseSound_2, $LoseSound_3][rand.randi_range(0, 2)].play()
	bars = preload("res://bars.tscn").instance()
	bars.scale = Vector2(0.5, 0.5)
	get_tree() \
		.get_nodes_in_group("camera")[0] \
		.add_child(bars)
#	bars.transform.origin.y = 616
	bars.transform.origin.y = 300
	bars.transform.origin.x = -256
	bars.z_index = 104
	
	lose_state = "bars_up"
	calc_final_stats()
	levels_won = 0
	total_gold_stolen = 0
	stats = null

func win_level():
	if lose_state == null:
		$WinSound.play()
		levels_won += 1
		current_level.win_level()
		stats = null
