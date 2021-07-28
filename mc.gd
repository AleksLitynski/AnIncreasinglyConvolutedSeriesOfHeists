extends KinematicBody2D

enum ANIM_STATE { IDLE, WALK, JUMP, THROW, THROW_HOLD, GRAB }
enum PRESS_STATES { NONE, START, MIDDLE, RELEASE, END }

var sleep_all = false

var frame_times = {
	ANIM_STATE.IDLE: 1.0,
	ANIM_STATE.WALK: 0.25,
	ANIM_STATE.JUMP: 1.0, # not used, but needs to be something
	ANIM_STATE.THROW: 0.3,
	ANIM_STATE.THROW_HOLD: 0.3,
	ANIM_STATE.GRAB: 0.4,
}
var anim = {
	"pressed_state_flags": {},
	"pressed_state": PRESS_STATES.END,
	"locked": false,
	"paused": false,
	"time": 0,
	"start_time": 0,
	"state": ANIM_STATE.IDLE,
	"prev_state": ANIM_STATE.IDLE,
}

var motion: = {
	"velocity": Vector2(),
	"gravity": 10,
	"speed": 30,
	"max_speed": 175,
}
var jump = {
	"active": false,
	"max": 55,
	"current": 0,
	"falloff": 0.9,
}

var gold = []
var max_gold_weight = 14.0
var thrown = null
var default_throw_velocity = Vector2(15, -10)
var throw_time = 0
var throw_charge_meter = preload("res://charge_level.tscn").instance()
var throw_charge_meter_target_y = 120

var rand
func _ready():
	rand = RandomNumberGenerator.new()
	rand.randomize()
	get_tree().get_nodes_in_group("camera")[0].add_child(throw_charge_meter)
	throw_charge_meter.rect_position = Vector2(-64, 150)
	throw_charge_meter_target_y = 150
	get_tree().get_nodes_in_group("camera")[0].z_index = 101

func show_anim(name):
	$sprite.texture = load("res://sprites/%s.png" % name)

func set_anim_state(new_state):
	if !anim["locked"]:
		anim["state"] = new_state

func pressed_state(test, state_name):
	var state_changed = false
	# tracks if the button can be pressed right now. Default to "yes
	if !anim["pressed_state_flags"].has(state_name):
		anim["pressed_state_flags"][state_name] = true

	# if we're already in the given state, run the animation to completion:
	if anim["state"] == state_name:
		var current_time = anim["time"] - anim["start_time"]
		if current_time >= frame_times[anim["state"]] / 2 and anim["pressed_state"] == PRESS_STATES.START:
			anim["pressed_state"] = PRESS_STATES.MIDDLE
			state_changed = true
		if current_time > frame_times[anim["state"]]: # if the animation is done...
			anim["pressed_state_flags"][state_name] = false # indicate it can't be played again...
			anim["paused"] = true # and pause all animations
			anim["passed_middle"] = true
			if anim["pressed_state"] == PRESS_STATES.MIDDLE:
				anim["pressed_state"] = PRESS_STATES.RELEASE
				state_changed = true
			if !test: # until we release the button
				anim["locked"] = false # then, allow other animations and re-enable this one
				anim["paused"] = false
				anim["pressed_state_flags"][state_name] = true
				anim["pressed_state"] = PRESS_STATES.END
				state_changed = true

	# if the animation hasn't started yet, start it and lock out other animations
	if test and anim["pressed_state_flags"][state_name]:
		set_anim_state(state_name)
		anim["locked"] = true
		if anim["pressed_state"] == PRESS_STATES.END:
			anim["pressed_state"] = PRESS_STATES.START
			state_changed = true

	return anim["pressed_state"] if state_changed else PRESS_STATES.NONE

func animate():
	var change = anim["state"] != anim["prev_state"]
	if change:
		anim["start_time"] = anim["time"]
	var frame = stepify(
		(anim["time"] - anim["start_time"]) / frame_times[anim["state"]],
		1)
	anim["prev_state"] = anim["state"]

	match anim["state"]:
		ANIM_STATE.IDLE:
			if !is_on_floor():
				show_anim("mc_idle1")
				anim["start_time"] = anim["time"]
			else:
				if fmod(frame, 2):
					show_anim("mc_idle1")
				else:
					show_anim("mc_idle2")
		ANIM_STATE.WALK:
			if fmod(frame, 2):
				show_anim("mc_idle1")
			else:
				show_anim("mc_move2")
		ANIM_STATE.JUMP:
			show_anim("mc_jump")
		ANIM_STATE.THROW:
			show_anim("mc_grab2")
		ANIM_STATE.THROW_HOLD:
			show_anim("mc_grab1")
		ANIM_STATE.GRAB:
			if fmod(frame, 2):
				show_anim("mc_grab2")
			else:
				show_anim("mc_grab1")

func move_anchors(on_left):
	if !on_left:
		$grabbox.transform.origin.x = 24
		$goldanchor.transform.origin.x = -16
		$throwanchor.transform.origin.x = 20
	else:
		$grabbox.transform.origin.x = -16
		$goldanchor.transform.origin.x = 16
		$throwanchor.transform.origin.x = -20

func encumberment_dampener(jump):
	if jump:
		return 1 - (len(gold) / (max_gold_weight * 2))
	return 1 - (len(gold) / max_gold_weight)

func _physics_process(delta):
	
	# remove all gold that was picked up by other processes
	var new_golds = []
	for g in gold:
		if g.get_parent():
			new_golds.append(g)
	gold = new_golds
	
	if sleep_all:
		return

	if !anim["paused"]:
		anim["time"] += delta
	set_anim_state(ANIM_STATE.IDLE)
	
	if abs(throw_charge_meter.rect_position.y - throw_charge_meter_target_y) > 0.2:
		var dir = 1 if (throw_charge_meter.rect_position.y < throw_charge_meter_target_y) else -1
		throw_charge_meter.rect_position.y += delta * 200 * dir
	else:
		throw_charge_meter.rect_position.y = throw_charge_meter_target_y

	var lr_move = 0
	if Input.is_action_pressed("left"):
		lr_move -= 1
	elif Input.is_action_pressed("right"):
		lr_move += 1
	else:
		motion["velocity"].x = lerp(motion["velocity"].x, 0, 0.2)

	if lr_move != 0:
		$sprite.flip_h = false if lr_move > 0 else true
		move_anchors($sprite.flip_h)
		if is_on_floor():
			set_anim_state(ANIM_STATE.WALK)
		motion["velocity"].x = clamp(motion["velocity"].x + (motion["speed"] * lr_move), 
			-motion["max_speed"],
			motion["max_speed"]) * encumberment_dampener(false)
		
	if lr_move != 0 and is_on_floor():
		if !$FootstepsSound.playing:
			$FootstepsSound.play()
	else:
		$FootstepsSound.stop()

	if is_on_floor() and Input.is_action_pressed("jump") and !jump["active"]:
		$JumpSound.play()
		jump["active"] = true
		motion["velocity"].y -= jump["current"] * encumberment_dampener(true)

	if Input.is_action_pressed("jump") and jump["active"]:
		jump["current"] *= jump["falloff"]
		motion["velocity"].y -= stepify(jump["current"], 0.1) * encumberment_dampener(true)

	if !Input.is_action_pressed("jump"):
		jump["active"] = false
		jump["current"] = jump["max"]

	if motion["velocity"].y < 0:
		set_anim_state(ANIM_STATE.JUMP)

	var throw_state = pressed_state(Input.is_action_pressed("throw"), ANIM_STATE.THROW)
	var grab_state = pressed_state(Input.is_action_pressed("grab"), ANIM_STATE.GRAB)

	if grab_state == PRESS_STATES.START:
		var bodies = $grabbox.get_overlapping_bodies()
		var found_gold = false

		# given the choice, pick up gold....
		for b in bodies:
			if b.is_in_group("gold"):
				$PickupSound.play()
				b.set_target($goldanchor)
				b.disable_collisions_for(self)
				gold.push_back(b)
				found_gold = true
				break # only pick up one per grab
		
		# if there was no gold to grab, push a box...
		if !found_gold:
			for b in bodies:
				if b.is_in_group("crate"):
					b.apply_central_impulse((b.global_transform.origin - global_transform.origin).normalized() * 14_000)
					break

	if throw_state == PRESS_STATES.START:
		if (len(gold) > 0):
			thrown = gold.pop_back()
			thrown.set_target($throwanchor)
			thrown.set_orbit(false)
			throw_time = OS.get_system_time_msecs()
			throw_charge_meter_target_y = 120
			throw_charge_meter.value = 0

	var time_held = min(OS.get_system_time_msecs() - throw_time, 3_000.0)
	throw_charge_meter.value = round((time_held / 3_000) * 10) * 10
	
	if throw_state == PRESS_STATES.END and thrown != null:
		# clear all physics on the gold bar
		
		[$throw_1, $throw_2, $throw_3][rand.randi_range(0, 2)].play()
		
		thrown.set_target()
		thrown.set_linear_velocity(Vector2(0, 0))
		thrown.set_angular_velocity(0)
		thrown.set_orbit(true)
		
		thrown.enable_collisions_in(1.0)
		
		var velo = default_throw_velocity
		var force = Vector2(-velo.x if $sprite.flip_h else velo.x, velo.y) * \
			2_000 * Vector2(max(time_held, 800) / 800, max(time_held, 800) / 800)

		thrown.apply_central_impulse(force)
		throw_charge_meter_target_y = 150
		
		# raise arm after throw
		pressed_state(true, ANIM_STATE.THROW_HOLD)
		
		# forget about it
		thrown = null

	animate()
	
	# always lower arm after throwing something
	pressed_state(false, ANIM_STATE.THROW_HOLD)

	motion["velocity"].y += motion["gravity"]
	motion["velocity"] = move_and_slide(motion["velocity"], Vector2.UP, false, 4, PI/4, false)
	
	for index in get_slide_count():
		var collision = get_slide_collision(index)
		if collision.collider.is_in_group("gold"):
			collision.collider.apply_central_impulse(-collision.normal * 600)
			
		if collision.collider.is_in_group("crate"):
			collision.collider.apply_central_impulse(-collision.normal * 1200)


func moving():
	var velo = motion["velocity"]
	return velo.x > 0.1 or velo.x < -0.1 or velo.y > 0.1 or velo.y < -0.1

func _input(ev):
	if ev.is_action_pressed("restart"):
		var main = get_tree().get_nodes_in_group("main")[0]
		main.load_level(main.current_level.level_id, false)
	
	if ev.is_action_pressed("down"):
		for shelf in get_tree().get_nodes_in_group("shelf"):
			shelf.add_collision_exception_with(self)
		
	if ev.is_action_released("down"):
		for shelf in get_tree().get_nodes_in_group("shelf"):
			shelf.remove_collision_exception_with(self)
