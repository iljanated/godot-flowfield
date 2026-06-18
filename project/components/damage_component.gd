extends Node2D
class_name DamageComponent

signal damage_taken

func take_damage() -> void:
	damage_taken.emit()