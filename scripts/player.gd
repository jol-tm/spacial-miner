extends CharacterBody2D

const SPEED = 500
const MAX_SPEED = 500
var cur_o2 = Global.o2
var cur_fuel = Global.fuel

func _physics_process(delta: float) -> void:
	var moving = false
	var mouse_pos = get_global_mouse_position()
	var ang = (Global.gravity_center - global_position).angle() - PI / 2
	# movimentation
	if cur_fuel > 0:
		if Input.is_action_pressed("ui_left"):
			moving = true
			velocity.x -= SPEED * delta
			$body.rotation_degrees = lerp($body.rotation_degrees, -15.0, 0.1)
		elif Input.is_action_pressed("ui_right"):
			moving = true
			velocity.x += SPEED * delta
			$body.rotation_degrees = lerp($body.rotation_degrees, 15.0, 0.1)
			
		if Input.is_action_pressed("ui_up"):
			moving = true
			velocity.y -= SPEED * delta
		elif Input.is_action_pressed("ui_down"):
			moving = true
			velocity.y += SPEED * delta

	if moving:
		propulsion()
		consume_fuel()
	else:
		slow_down()
		
	if velocity.length() > MAX_SPEED:
		velocity = velocity.normalized() * MAX_SPEED
		
	position.y =  clamp(position.y, position.y, 250)
	move_and_slide()
	
	# base o2, fuel management and compass
	if Global.gravity:
		$compass.visible = false
		rotation = lerp(rotation, ang, 0.1)
		if cur_o2 < Global.o2:
			refuel_o2()
		if cur_fuel < Global.fuel:
			refuel_fuel()
	else:
		$compass.visible = true
		rotation = lerp(rotation, 0.0, 0.1)
		consume_o2()
	$compass.rotation = (Global.gravity_center - global_position).angle() + PI / 2
	
	if cur_o2 <= 0:
		for i in Global.inventory:
			Global.inventory[i] = 0
		global_position = $"../planet".global_position
	
	# updating inventory
	update_inventory()
	
	# laser aiming
	$crosshair.global_position = mouse_pos
	$laser_cannon/RayCast2D.look_at(mouse_pos)
	$laser_cannon.look_at(mouse_pos)
	$laser_cannon/laser.size.x = 1000
	if mouse_pos < global_position:
		$laser_cannon/cannon.flip_v = true
		$body/astronaut.flip_h = true
		$body/jetpack.position.x = 6
	else:
		$laser_cannon/cannon.flip_v = false
		$body/astronaut.flip_h = false
		$body/jetpack.position.x = -6
		
	# laser activation
	if Input.is_action_pressed("click"):
		$laser_cannon/laser.visible = true
		$crosshair.rotation_degrees += 10
		if (!$laser_cannon/cannon/AnimationPlayer.is_playing()):
			$laser_cannon/cannon/AnimationPlayer.play("active")
			
		if $laser_cannon/RayCast2D.is_colliding():
			var collider = $laser_cannon/RayCast2D.get_collider()
			var adjust_factor = 7
			if collider.is_in_group("meteorites"):
				var distance = (collider.global_position - global_position).length() / adjust_factor
				$laser_cannon/laser.size.x = distance
				$laser_cannon/laser/energy_ball.position.x = distance
				collider.call("receive_damage")
		else:
			$laser_cannon/laser/energy_ball.position.x = 200
	else:
		var start_rotation = int($crosshair.rotation_degrees) % 360
		$laser_cannon/laser.visible = false
		$crosshair.rotation_degrees = lerp(start_rotation, 0, 0.1)
		$laser_cannon/cannon/AnimationPlayer.stop()

func propulsion():
	$body/propulsion_left.emitting = true 
	$body/propulsion_right.emitting = true
	
func slow_down():
	velocity = lerp(velocity, Vector2(0, 0), 0.005) 
	$body.rotation_degrees = lerp($body.rotation_degrees, 0.0, 0.1) 
	$body/propulsion_left.emitting = false 
	$body/propulsion_right.emitting = false

func consume_fuel():
	cur_fuel -= 0.1
	$ui/fuel_bar/out/bar.size.x = cur_fuel / Global.fuel * 150

func refuel_fuel():
	cur_fuel += 0.5
	$ui/fuel_bar/out/bar.size.x = cur_fuel / Global.fuel * 150

func consume_o2():
	cur_o2 -= 0.1
	$ui/o2_bar/out/bar.size.x = cur_o2 / Global.o2 * 150

func refuel_o2():
	cur_o2 += 0.5
	$ui/o2_bar/out/bar.size.x = cur_o2 / Global.o2 * 150
	
func update_inventory():
	for node in $ui/inventory/ColorRect/GridContainer.get_children():
		node.queue_free()
	for item in Global.inventory:
		var label = Label.new()
		if Global.inventory[item] > 0:
			$ui/inventory/ColorRect/GridContainer.add_child(label)
			label.text = item + ": " + str(Global.inventory[item])
			
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("meteorites"):
		body.call("push", global_position)

func _on_magnet_area_area_entered(area: Area2D) -> void:
	if area.get_parent().is_in_group("ores"):
		area.get_parent().call("toogle_magnet")

func _on_magnet_area_area_exited(area: Area2D) -> void:
	if area.get_parent().is_in_group("ores"):
		area.get_parent().call("toogle_magnet")
