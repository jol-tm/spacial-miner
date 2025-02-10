extends RigidBody2D

var magnet = false
var type

func _ready() -> void:
	set_type()
	angular_velocity = randi_range(-20, 20)
	apply_impulse(Vector2(randi_range(-300, 300), randi_range(-300, 300)))

func _physics_process(delta: float) -> void:
	if magnet:
		var player_pos = get_parent().get_node("player").global_position
		var dir = (player_pos - global_position).normalized()
		linear_velocity += dir * 500 * delta
	else:
		linear_velocity = lerp(linear_velocity, Vector2(0.0, 0.0), 0.05)
		
func set_type():
	var tex_path = $Sprite2D.texture.get_path()
	var type_id = int(tex_path.substr(tex_path.length() - 5, 1))
	match type_id:
		1: type = "Iron"
		2: type = "Aluminium"
		3: type = "Cooper"
		4: type = "Cobalt"
		5: type = "Platinum"
		6: type = "Gold"
		7: type = "Diamond"

func toogle_magnet():
	magnet = !magnet

func _on_loot_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		get_looted(body)
		
func get_looted(body):
	$CollisionShape2D.set_deferred("disabled", true)
	$loot_area/CollisionShape2D.set_deferred("disabled", true)
	$AnimationPlayer.play("loot")
	$get_looted.play()
	await $AnimationPlayer.animation_finished
	Global.inventory[type] += 1
	body.call("update_inventory")
	queue_free()
