extends RigidBody2D

var hp
var cur_hp
var size

func _ready() -> void:
	random_hp_and_size()
	random_meteorite()
	random_forces()

func _physics_process(delta: float) -> void:
	check_distance()

func check_distance():
	var player = get_parent().get_child(1)
	var distance = (player.global_position  - global_position).length()
	if (distance >= 5000):
		queue_free()
		get_parent().call("spawn_meteorite", 1)
		print("Meteorito muito longe, destruído e colocado um mais perto")

func random_hp_and_size():
	hp = randi_range(100, 500)
	cur_hp = hp
	if hp <= 200:
		size = 4
	elif hp >= 400:
		size = 8
	else:
		size = hp / 50
	
	$Sprite2D.scale = Vector2(size, size)

func random_meteorite():
	var n = randi_range(1, 7)
	$Sprite2D.texture = load("res://sprites/meteorites/meteorite_" + str(n) + ".png")

func random_forces():
	add_constant_force(Vector2(randi_range(-5, 5), randi_range(-5, 5)))
	add_constant_torque(randi_range(-500, 500))

func push(direction, force):
	var impulse = (direction - global_position).normalized() * -force
	apply_impulse(impulse)

func receive_damage():
	if cur_hp <= 0:
		destroy()
	else:
		cur_hp -= Global.player_damage
		$shatter.emitting = true
	
	$hp_bar.visible = true
	$hp_bar/hp.size.x = cur_hp / float(hp) * 40
	
func destroy():
	var fade = create_tween().tween_property(self, "modulate", Color(1,1,1,0), 1)
	$CollisionShape2D.disabled = true
	$Area2D/CollisionShape2D.disabled = true
	spawn_ores()
	await get_tree().create_timer(3).timeout
	queue_free()
	get_parent().call("spawn_meteorite", 1)
	print("Meteorito destruído, novo saindo")

func spawn_ores():
	print(global_position)
	var tex_path = $Sprite2D.texture.get_path()
	var type = tex_path.substr(tex_path.length() - 5, 1)
	var ore_scene = preload("res://scenes/ore.tscn")
	var ore_amount = (hp / 100)
	
	for ores in ore_amount:
		var ore = ore_scene.instantiate()
		var pos_x = randi_range(global_position.x - 5, global_position.x + 5)
		var pos_y = randi_range(global_position.y - 5, global_position.y + 5)
		ore.position = Vector2(pos_x, pos_y)
		ore.get_node("Sprite2D").texture = load("res://sprites/ores/ore_" + type + ".png")
		get_parent().add_child(ore)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		push(body.global_position, body.velocity.length())
