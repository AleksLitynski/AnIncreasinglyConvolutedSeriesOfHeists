extends Node2D

var level_name = "Level 1"
var level_description = """
The first into, a call to arms. A starting place. You're new house in the country.

Power's out :(
"""

var state = "drive_in" # drive_in, follow_cam, crash_out, playing, lose, win

onready var van = preload("res://Car.tscn").instance()
onready var player = preload("res://mc.tscn").instance()

func _ready():
	add_child(van)
	van.scale = Vector2(0.8, 0.8)
	$Camera.zoom = Vector2(1, 1)
	van.transform.origin = $end.transform.origin
	$Camera.transform.origin = $end.transform.origin
	$Camera.transform.origin.x -= 750
	van.transform.origin.x -= 1400

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
			# swap sprites for broken window sprites
			# jump player to spawn
			# lock camera to player
			pass
		"land":
			if fmod(player.get_node("sprite").rotation, (2 * PI)) < 0.4:
				player.get_node("sprite").rotation = 0
				state = "playing"
				player.sleep_all = false
			else:
				player.get_node("sprite").rotation += delta * 20
		"playing":
			$Camera.transform.origin = player.transform.origin
		"lose":
			pass
		"win":
			pass
	# DO THE CRASH IN
	# DRIVE VAN IN
	# FLY OUT PLAYER TO SPAWN POINT
	# SHATTER WINDSHIELD
