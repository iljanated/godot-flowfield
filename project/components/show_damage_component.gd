extends Node2D
class_name ShowDamageComponent

@onready var animated_sprite_2d : AnimatedSprite2D = $"../AnimatedSprite2D"
@onready var timer : Timer = $Timer

@export var color_duration : float = 0.1

func _on_damage_component_damage_taken() -> void:
	animated_sprite_2d.set_instance_shader_parameter("is_damage_color", true)
	timer.start(color_duration)

func _on_timer_timeout() -> void:
	animated_sprite_2d.set_instance_shader_parameter("is_damage_color", false)