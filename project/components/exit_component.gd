extends Node2D
class_name ExitComponent

signal exit_reached

func on_exit_reached() -> void:
	print("Exit reached!")
	exit_reached.emit()
