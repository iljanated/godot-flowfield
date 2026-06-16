extends Node2D
class_name PlayerComponent

@onready var walk_component : WalkComponent = $"../WalkComponent"

func _physics_process(delta: float) -> void:
	var input_direction = Vector2(Input.get_axis("move_left", "move_right"), Input.get_axis("move_up", "move_down"))
	if input_direction != Vector2.ZERO:
		walk_component.direction = input_direction.normalized()
	else:
		walk_component.direction = Vector2.ZERO

	walk_component.sprinting = Input.is_action_pressed("sprint")