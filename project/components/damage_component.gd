extends Node2D
class_name DamageComponent

signal damage_taken

func on_damage_taken() -> void:
	print("Damage taken!")
	damage_taken.emit()