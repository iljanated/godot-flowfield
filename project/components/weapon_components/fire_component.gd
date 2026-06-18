extends Node2D
class_name FireComponent

@onready var ammo_component: AmmoComponent = $"../AmmoComponent"

@export var fire_rate: float = 0.1
@export var recoil: float = 0.0 #100.0

var time_since_last_fire: float = 0.0
var fire_result: FireResult = FireResult.new()

func _physics_process(delta: float) -> void:
	time_since_last_fire += delta

func fire(direction: Vector2, delta: float) -> FireResult:
	if time_since_last_fire >= fire_rate:
		time_since_last_fire = 0.0

		var ammo = ammo_component.take_ammo(delta)
		if ammo > 0:
			var target_transform: Transform2D = Transform2D(direction.angle(), global_position)
			WorldSignals.spawn.emit("bullet", target_transform, "res://weapons/bullet.tscn")
			fire_result.recoil_direction = - direction
			fire_result.recoil_velocity = recoil
			return fire_result
	return null
