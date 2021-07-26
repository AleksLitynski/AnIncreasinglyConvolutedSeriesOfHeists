extends Area2D

var cash = preload("res://cash.tscn")

func _ready():
	randomize()


var collected = []

func _on_Area2D_body_entered(body):
	if collected.find(body.name) != -1:
		print("duplicate" + body.name)
	if body.is_in_group("gold") and collected.find(body.name) == -1:
		
		collected.append(body.name)

		var c_instance = cash.instance()
		body.get_parent().add_child(c_instance)
		var center = $CollisionShape2D.get_global_transform().origin
		var widHei = $CollisionShape2D.shape.extents
		c_instance.global_transform.origin = Vector2(
			rand_range(center.x - widHei.x, center.x + widHei.x),
			rand_range(center.y - widHei.y, center.y + widHei.y))
		c_instance.z_index = 100
		c_instance.playing = true
		$"../CollectGold".play()

		body.fade_out(c_instance.global_transform.origin)
		var stats = get_tree().get_nodes_in_group("main")[0].add_gold()
