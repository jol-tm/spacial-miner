extends Node2D

var max_spawn_distance_h = 3000
var min_spawn_distance_v = 500
var meteorite_scene = preload("res://scenes/meteorite.tscn")
var star_scene = preload("res://scenes/shooting_star.tscn")

func _ready() -> void:
	spawn_meteorite(100)
	$random_events.start()
	
func _process(delta: float) -> void:
	pass

func spawn_meteorite(amount):
	for i in range(amount):
		var x_pos = randi_range($player.global_position.x - max_spawn_distance_h, $player.global_position.x + max_spawn_distance_h)
		var y_pos = randi_range($player.global_position.y - min_spawn_distance_v , $player.global_position.y - max_spawn_distance_h)
		var meteorite = meteorite_scene.instantiate()
		meteorite.position = Vector2(x_pos, y_pos)
		add_child(meteorite)

func _on_random_events_timeout() -> void:
	$random_events.wait_time = randi_range(10, 15)
	var screen = DisplayServer.window_get_size()
	var x_pos = randi_range($player.global_position.x - screen.x / 2, $player.global_position.x + screen.x / 2)
	var y_pos = randi_range($player.global_position.y - screen.y / 2 , $player.global_position.y + screen.y / 2)
	var star = star_scene.instantiate()
	star.position = Vector2(x_pos, y_pos)
	add_child(star)
