extends Node2D
class_name SpawnComponent

signal spawned(spawn_component : SpawnComponent)
signal despawned(spwan_component : SpawnComponent)
signal despawn_requested(spawn_component : SpawnComponent)

var can_spawn: bool = true

func despawn() -> void:
    despawn_requested.emit(self)

func on_spawn() -> void:
    spawned.emit(self)

func on_despawn() -> void:
    despawned.emit(self)