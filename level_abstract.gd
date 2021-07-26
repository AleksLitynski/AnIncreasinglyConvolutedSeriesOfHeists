extends Node2D

var state = "drive_in" # drive_in, follow_cam, crash_out, playing, lose, win

onready var van = preload("res://Car.tscn").instance()
onready var player = preload("res://mc.tscn").instance()
onready var clock = preload("res://clock.tscn").instance()
onready var golds = Node2D.new()
var gold_icon = preload("res://gold_icon.tscn")
var gold_color = preload("res://sprites/goldbar3.png")
var gold_bw = preload("res://sprites/goldbar3_gray.png")

func _ready():
	add_child(van)
	get_tree().get_nodes_in_group("camera")[0].add_child(clock)
	get_tree().get_nodes_in_group("camera")[0].add_child(golds)
	van.scale = Vector2(0.8, 0.8)
	$Camera.zoom = Vector2(0.5, 0.5)
	van.transform.origin = $end.transform.origin
	$Camera.transform.origin = $end.transform.origin
	$Camera.transform.origin.x -= 750
	van.transform.origin.x -= 1400

	clock.transform.origin.x = 225
	clock.transform.origin.y = -115
	clock.scale = Vector2(0.8, 0.8)
	clock.z_index = 101
	golds.z_index = 101
	golds.transform.origin.x = -235
	golds.transform.origin.y = -130
	var gc = len(get_tree().get_nodes_in_group("gold"))
	var idx = 0.0
	var max_width = 400.0
	for gold in get_tree().get_nodes_in_group("gold"):
		var i = gold_icon.instance()
		i.texture = gold_bw
		golds.add_child(i)
		i.transform.origin = Vector2(
			ceil(fmod((30.0 * idx), max_width)),
			floor(((30.0 * idx) / max_width)) * 30.0
		)
		idx += 1.0
	

func _process(delta):
	match state:
		"drive_in":
			if (van.transform.origin - $Camera.transform.origin).length() < 10:
				state = "follow_cam"
			else:
				van.transform.origin.x += delta * 800
		"follow_cam":
			if (van.transform.origin - $end.transform.origin).length() < 10:
				state = "crash_out"
				add_child(player)
				player.transform.origin = van.transform.origin
				player.sleep_all = true
				player.show_anim("mc_jump")
				van.play("broke")
			else:
				van.transform.origin.x += delta * 800
				$Camera.transform.origin = van.transform.origin
		"crash_out":
			if (player.transform.origin - $start.transform.origin).length() < 10:
				state = "land"
			else:
				player.transform.origin += delta * 700 * ($start.transform.origin - player.transform.origin).normalized()
				player.get_node("sprite").rotation += delta * 16
				$Camera.transform.origin = player.transform.origin
		"land":
			if fmod(player.get_node("sprite").rotation, (2 * PI)) < 0.4:
				player.get_node("sprite").rotation = 0
				state = "playing"
				clock.frame = 0
				clock.play("default")
				player.sleep_all = false
				get_tree().get_nodes_in_group("main")[0].start_level()
			else:
				player.get_node("sprite").rotation += delta * 20
		"playing":
			$Camera.transform.origin = player.transform.origin
		"win_jump_car":
			if (player.transform.origin - $end.transform.origin).length() < 2:
				state = "win_drive_out"
				player.get_parent().remove_child(player)
			else:
				player.transform.origin += delta * 700 * ($end.transform.origin - player.transform.origin).normalized()
				player.get_node("sprite").rotation += delta * 16
				$Camera.transform.origin = player.transform.origin
		"win_drive_out":
			if van.transform.origin.x < get_viewport().size.x / 2 + 200:
				van.transform.origin.x += delta * 800
				$Camera.transform.origin = van.transform.origin
			else:
				state = "win_drive_away"
		"win_drive_away":
			if van.transform.origin.x < get_viewport().size.x + 200:
				van.transform.origin.x += delta * 900
			else:
				player.collision_layer = 2
				player.collision_mask = 2
				player.sleep_all = false
				get_tree().get_nodes_in_group("main")[0].goto_next_level()

func win_level():
	player.sleep_all = true
	player.show_anim("mc_jump")
	player.collision_layer = 2
	player.collision_mask = 2
	state = "win_jump_car"

func add_gold():
	print("add gold")
	for gold in golds.get_children():
		if gold.texture == gold_bw:
			gold.texture = gold_color
			break
