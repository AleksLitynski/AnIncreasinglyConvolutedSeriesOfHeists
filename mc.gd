extends KinematicBody2D


var velocity = Vector2()
var gravity = 10
var move_speed = 30
var max_move = 175
var jump = {
	"active": false,
	"max": 50,
	"current": 0,
	"falloff": 0.9,
}

func _process(delta):

	if Input.is_action_pressed("left"):
		velocity.x = max(-max_move, velocity.x - move_speed)
	elif Input.is_action_pressed("right"):
		velocity.x = min(max_move, velocity.x + move_speed)
	else:
		velocity.x = lerp(velocity.x, 0, 0.2)

	if is_on_floor():
#		$Camera2D/debug.text = 'on floor'
		if Input.is_action_pressed("jump") and !jump["active"]:
			jump["active"] = true
			velocity.y -= jump["current"]

	if Input.is_action_pressed("jump") and jump["active"]:
		jump["current"] *= jump["falloff"]
		velocity.y -= jump["current"]

	if !Input.is_action_pressed("jump"):
		jump["active"] = false
		jump["current"] = jump["max"]
		
		
	$Camera2D/debug.text = str(jump) + "\n" + str(velocity)

	velocity.y += gravity
	velocity = move_and_slide(velocity, Vector2.UP)
