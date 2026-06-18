extends Node2D
class_name RecoilComponent

@onready var walk_component : WalkComponent = $"../WalkComponent"
@onready var weapon_manager_component : WeaponManagerComponent = $"../WeaponManagerComponent"

func _ready() -> void:
	weapon_manager_component.weapon_fired.connect(_on_weapon_fired)
	
func _on_weapon_fired(result: FireResult) -> void:
	walk_component.add_impulse(result.recoil_direction, result.recoil_velocity, result.recoil_fly_time)
	
