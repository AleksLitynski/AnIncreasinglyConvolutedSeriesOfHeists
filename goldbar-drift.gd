extends Sprite

var period = Vector2()

func _ready():
	randomize()
	period.x = rand_range(0, 1)
	period.y = rand_range(0, 1)

func _process(delta):
	period.x += delta
	period.y += delta * 2
	offset.x = sin(period.x) * 2.5
	offset.y = sin(period.y) * 2.5


