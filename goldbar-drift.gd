extends RigidBody2D

var period = Vector2()
var orbit_radius = 2.5
var orbit_speed = 1
var target = null
var orbit = true

func _ready():
	randomize()
	period.x = rand_range(0, 1)
	period.y = rand_range(0, 1)

func _process(delta):
	period.x += delta * orbit_speed
	period.y += delta * 2 * orbit_speed
	if orbit:
		$goldbar.offset.x = sin(period.x) * orbit_radius
		$goldbar.offset.y = sin(period.y) * orbit_radius
	else:
		$goldbar.offset.x = lerp($goldbar.offset.x, 0, 0.1)
		$goldbar.offset.y = lerp($goldbar.offset.y, 0, 0.1)
		rotation = lerp(rotation, 0, 0.1)
	
	if target != null:
		var t = target.get_global_transform().origin - get_global_transform().origin
		transform.origin += t * 10 * delta

func set_orbit(orb = true):
	orbit = orb

func set_target(t = null):
	if t != null:
		orbit_radius = 7.5
		orbit_speed = 1.5
	else:
		orbit_radius = 2.5
		orbit_speed = 1
	target = t
