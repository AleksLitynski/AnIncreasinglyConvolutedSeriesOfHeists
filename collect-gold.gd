extends Area2D

var cash = preload("res://cash.tscn")

func _ready():
	randomize()

var collected = []

func collect_gold(gold):
	if collected.find(gold.name) == -1:
		collected.append(gold.name)

		var c_instance = cash.instance()
		gold.get_parent().add_child(c_instance)
		var center = $CollisionShape2D.get_global_transform().origin
		var widHei = $CollisionShape2D.shape.extents
		c_instance.global_transform.origin = Vector2(
			rand_range(center.x - widHei.x, center.x + widHei.x),
			rand_range(center.y - widHei.y, center.y + widHei.y))
		c_instance.z_index = 100
		c_instance.playing = true
		$"../CollectGold".play()

		gold.fade_out(c_instance.global_transform.origin)
		var stats = get_tree().get_nodes_in_group("main")[0].add_gold()


func _on_Area2D_body_entered(body):
	if body.is_in_group("mc"):
		# collect all gold from bag
		for g in body.gold:
			collect_gold(g)
		
	if body.is_in_group("gold"):
		collect_gold(body)


func _process(delta):
	for body in get_overlapping_bodies():
		if body.is_in_group("mc"):
			# collect all gold from bag
			for g in body.gold:
				collect_gold(g)
