extends RigidBody2D

var period = Vector2()
var orbit_radius = 2.5
var orbit_speed = 1
var target = null
var orbit = true
var fade_out = null

func _ready():
	randomize()
	period.x = rand_range(0, 1)
	period.y = rand_range(0, 1)

func _process(delta):
	if fade_out:
		z_index = 99
		var t = fade_out - get_global_transform().origin
		transform.origin += t * 8 * delta
		modulate.a -= delta * 8.0
		if modulate.a <= 0:
			get_parent().remove_child(self)
		return

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
	else:
		# slowly rotate the gold so it faces up once it lands on the ground
		if fmod(rotation, PI * 2) > 0.2:
			var rot_speed = 1 * (1 if fmod(rotation, PI * 2) > PI else -1)
			rotation += delta * rot_speed
		else:
			rotation = 0
	
	

func set_orbit(orb = true):
	orbit = orb

func set_target(t = null):
	if t != null:
		orbit_radius = 7.5
		orbit_speed = 1.5
		sleeping = true
		collision_mask = 2
		collision_layer = 2
	else:
		orbit_radius = 2.5
		orbit_speed = 1
		collision_mask = 1
		collision_layer = 1
	target = t

func fade_out(target):
	fade_out = target
	
var col_exception = null
var timer = null

func disable_collisions_for_time(target, time_to_unset):
	col_exception = target
	add_collision_exception_with(col_exception)
	timer = Timer.new()
	timer.connect("timeout", self, "unset_done")
	add_child(timer)
	timer.start(time_to_unset)

func unset_done():
	remove_collision_exception_with(col_exception)
	remove_child(timer)
