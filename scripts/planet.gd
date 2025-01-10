extends CharacterBody2D

func _ready() -> void:
	Global.gravity_center = global_position


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "player":
		Global.gravity = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "player":
		Global.gravity = false
