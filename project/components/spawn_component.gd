extends Node2D
class_name SpawnComponent

signal spawned
signal despawned

var can_spawn: bool = true

func despawn() -> void:
    despawned.emit(self)

func on_spawn() -> void:
    # Custom logic for when the component is spawned
    emit_signal("spawned")

func on_despawn() -> void:
    # Custom logic for when the component is despawned
    emit_signal("despawned")