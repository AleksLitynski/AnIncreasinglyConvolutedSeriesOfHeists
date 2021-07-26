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
	
	if target != null:
		var t = target.get_global_transform().origin - get_global_transform().origin
		#	apply_central_impulse()
		set_linear_velocity(t * 10 * delta * 150)
#		transform.origin += 
	else:
		# slowly rotate the gold so it faces up once it lands on the ground
		if fmod(rotation, PI * 2) > 0.2:
			var rot_speed = 1 * (1 if fmod(rotation, PI * 2) > PI else -1)
			rotation += delta * rot_speed
		else:
			rotation = 0

func set_orbit(orb = true):
	orbit = orb
	rotation = 0

func set_target(t = null):
	if t != null:
		orbit_radius = 7.5
		orbit_speed = 1.5
	else:
		orbit_radius = 2.5
		orbit_speed = 1
	target = t
	collision_layer = 1
	collision_mask = 1
	if target and ("name" in target) and target.name == "goldanchor":
		collision_layer = 0
		collision_mask = 0

func fade_out(target):
	fade_out = target

var col_exception = null
var timer = null
func disable_collisions_for(target):
	col_exception = target
	add_collision_exception_with(col_exception)
	for gold in get_tree().get_nodes_in_group("gold"):
		add_collision_exception_with(gold)
	
func enable_collisions_in(time):
	timer = Timer.new()
	timer.connect("timeout", self, "unset_done")
	add_child(timer)
	timer.start(time)

func unset_done():
	remove_collision_exception_with(col_exception)
	for gold in get_tree().get_nodes_in_group("gold"):
		remove_collision_exception_with(gold)
	remove_child(timer)
