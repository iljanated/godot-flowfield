extends Node2D
class_name PlayerComponent

@onready var character_body_2d : CharacterBody2D = $".."
@onready var walk_component : WalkComponent = $"../WalkComponent"
@onready var weapon_manager_component : WeaponManagerComponent = $"../WeaponManagerComponent"
@onready var aim_component : AimComponent = $"../AimComponent"

func _physics_process(delta: float) -> void:
	var input_direction = Vector2(Input.get_axis("move_left", "move_right"), Input.get_axis("move_up", "move_down"))
	if input_direction != Vector2.ZERO:
		walk_component.direction = input_direction.normalized()
	else:
		walk_component.direction = Vector2.ZERO

	walk_component.sprinting = Input.is_action_pressed("sprint")

	if Input.is_action_pressed("fire_primary"):
		var active_weapon = weapon_manager_component.get_active_weapon()
		if active_weapon:
			active_weapon.fire(aim_component.direction, delta)
