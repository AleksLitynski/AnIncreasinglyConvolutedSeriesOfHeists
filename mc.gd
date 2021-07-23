extends KinematicBody2D


var velocity = Vector2()
var jumped = false

func grounded():
	var belows = $"below-box".get_overlapping_bodies()
	for below in belows:
		if below.is_in_group("tile"):
			return true
	return false

func _process(delta):
	velocity.y += 30

	if Input.is_action_pressed("left"):
		velocity.x = min(-500, velocity.x - 7)
	elif Input.is_action_pressed("right"):
		velocity.x = max(500, velocity.x + 7)
	else:
		velocity.x = 0

	var gd = grounded()
	if gd:
		if Input.is_action_pressed("jump") and !jumped:
			velocity.y -= 2100
			jumped = true
		if !Input.is_action_pressed("jump"):
			jumped = false

	move_and_slide(velocity * delta * 10)
