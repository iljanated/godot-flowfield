extends Node2D
class_name WalkComponent

@export var character_body : CharacterBody2D
@export var base_speed : float = 70.0
@export var sprint_multiplier : float = 2.0

var direction : Vector2 = Vector2.UP
var sprinting : bool = false

func _physics_process(delta):
	if direction != Vector2.ZERO:

		var multiplier = sprint_multiplier if sprinting else 1.0

		var velocity = direction * base_speed * multiplier
		character_body.velocity = velocity
		character_body.move_and_slide()
