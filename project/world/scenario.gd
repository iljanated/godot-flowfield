extends Node2D
class_name Scenario

@export var timer : Timer

func _ready() -> void:
    timer.timeout.connect(_on_timer_timeout)
    timer.one_shot = true
    timer.wait_time = 1.0
    timer.start()

func _on_timer_timeout() -> void:
    var targetTransform: Transform2D = Transform2D.IDENTITY
    targetTransform.origin = Vector2(750, -150)
    WorldSignals.spawn.emit("enemy", targetTransform, "res://entities/enemy/enemy.tscn")
    timer.wait_time = randf_range(0.3, 2.0)
    timer.start()