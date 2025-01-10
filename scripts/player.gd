extends CharacterBody2D

const SPEED = 500
const GRAVITY = 100
const MAX_SPEED = 500

func _physics_process(delta: float) -> void:
	var moving = false
	var mouse_pos = get_global_mouse_position()
	# movimentation
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
	else:
		slow_down()
		
	if velocity.length() > MAX_SPEED:
		velocity = velocity.normalized() * MAX_SPEED
		
	position.y =  clamp(position.y, position.y, 250)
	move_and_slide()
	
	# gravity and compass
	if Global.gravity:
		var dir = (Global.gravity_center - global_position).normalized()
		var ang = (Global.gravity_center - position).angle() - PI / 2
		$compass.visible = false
		rotation = lerp(rotation, ang, 0.1)
		position += dir * GRAVITY * delta
	else:
		rotation = lerp(rotation, 0.0, 0.1)
		$compass.visible = true
		$compass.rotation = (Global.gravity_center - position).angle() + PI / 2
		
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

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("meteorites"):
		body.call("push", global_position)

func _on_magnet_area_area_entered(area: Area2D) -> void:
	if area.get_parent().is_in_group("ores"):
		area.get_parent().call("toogle_magnet")

func _on_magnet_area_area_exited(area: Area2D) -> void:
	if area.get_parent().is_in_group("ores"):
		area.get_parent().call("toogle_magnet")
