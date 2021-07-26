extends Area2D

var isPressed = false


func _ready():
	$red.visible = false
	$green.visible = false
	$blue.visible = false
	match get_parent().doorColor:
		Door.DoorColor.RED: $red.visible = true
		Door.DoorColor.GREEN: $green.visible = true
		Door.DoorColor.BLUE: $blue.visible = true

	$Timer.connect("timeout", self, "timeout_done")

func setState(pressed):
	if pressed:
		$green.frame = 0
		$blue.frame = 0
		$red.frame = 0
		get_parent().openDoor()
		$Timer.stop()
	else:
		$green.frame = 1
		$blue.frame = 1
		$red.frame = 1
		$Timer.stop()
		$Timer.start(3)
	
func timeout_done():
	if get_parent() != null:
		get_parent().closeDoor()
		$Timer.stop()
	

func _on_button_body_entered(body):
	if !isPressed:
		isPressed = true
		setState(true)

func _on_button_body_exited(body):
	var bodies = get_overlapping_bodies()
	if len(bodies) == 0:
		isPressed = false
		setState(false)
