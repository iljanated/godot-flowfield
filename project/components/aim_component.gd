extends Node2D
class_name AimComponent

var direction : Vector2 = Vector2.UP

func _physics_process(delta):
    direction = global_position.direction_to(get_global_mouse_position())
