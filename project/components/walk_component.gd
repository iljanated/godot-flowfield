extends Node2D
class_name WalkComponent

@onready var character_body : CharacterBody2D = $".."
@export var base_speed : float = 70.0
@export var sprint_multiplier : float = 2.0
@export var friction : float = 1000.0

var direction : Vector2 = Vector2.UP
var sprinting : bool = false
var _impulse_velocity : Vector2 = Vector2.ZERO

func _physics_process(delta):
	var walk_velocity = Vector2.ZERO
	if direction != Vector2.ZERO:
		var multiplier = sprint_multiplier if sprinting else 1.0
		walk_velocity = direction * base_speed * multiplier
	
	_impulse_velocity = _impulse_velocity.move_toward(Vector2.ZERO, friction * delta)
	
	character_body.velocity = walk_velocity + _impulse_velocity
	character_body.move_and_slide()

func add_impulse(impulse_direction: Vector2, impulse_velocity: float, impulse_fly_time: float) -> void:
	_impulse_velocity += impulse_direction * impulse_velocity