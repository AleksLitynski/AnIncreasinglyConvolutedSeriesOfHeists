extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	# load_level("main_menu", false)
	load_level("main_menu", false)

var current_level = null

func load_level(name, use_loader = true):

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

