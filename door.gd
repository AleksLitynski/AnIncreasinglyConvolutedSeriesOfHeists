extends StaticBody2D
class_name Door

enum DoorColor { GREEN, RED, BLUE }
export(DoorColor) var doorColor = DoorColor.GREEN setget setDoorColor, getDoorColor

func setDoorColor(newColor):
	doorColor = newColor
	$green.visible = false
	$green.visible = false
	$green.visible = false
	match doorColor:
		DoorColor.GREEN: $green.visible = true
		DoorColor.RED: $red.visible = true
		DoorColor.BLUE: $blue.visible = true

func getDoorColor():
	return doorColor

func _ready():
	$CollisionShape2D.shape = $CollisionShape2D.shape.duplicate()
	setDoorColor(doorColor)

func _process(delta):
	if $green.frame == 0:
		$CollisionShape2D.one_way_collision = true
		add_to_group("shelf")
	else:
		$CollisionShape2D.one_way_collision = false
		for player in get_tree().get_nodes_in_group("mc"):
			remove_collision_exception_with(player)
		remove_from_group("shelf")

func openDoor():
	if $green.frame != 0:
		$AnimationPlayer.play("open")

func closeDoor():
	if $green.frame != 3:
		$AnimationPlayer.play_backwards("open")
