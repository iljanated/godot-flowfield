extends Node2D
class_name Weapon

var is_active: bool = false

@onready var fire_component : FireComponent = $"FireComponent"

signal fired(fire_result: FireResult)

func fire(direction: Vector2, delta: float) -> void:
	if is_active:
		var result = fire_component.fire(direction, delta)
		if result:
			fired.emit(result)
