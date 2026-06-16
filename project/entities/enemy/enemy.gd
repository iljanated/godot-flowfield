extends CharacterBody2D
class_name Enemy

@onready var exit_component : ExitComponent = $ExitComponent
@onready var spawn_component : SpawnComponent = $SpawnComponent

func _ready():
	exit_component.exit_reached.connect(_on_exit_reached)
	spawn_component.spawned.connect(_on_spawned)
	spawn_component.despawned.connect(_on_despawned)

func _on_exit_reached():
	spawn_component.despawn()

func _on_spawned():
	print("Enemy spawned.")

func _on_despawned():
	print("Enemy despawned.")
	
