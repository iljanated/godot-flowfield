extends Node2D
class_name Bullet

@export var lifespan: float = 2.0
@export var speed: float = 400.0
@export var margin: float = 1.5

var time_alive: float = 0.0

@onready var spawn_component : SpawnComponent = $SpawnComponent

func _ready():
	spawn_component.spawned.connect(_on_spawned)
	spawn_component.despawned.connect(_on_despawned)

func _physics_process(delta: float) -> void:
	time_alive += delta
	if time_alive >= lifespan:
		spawn_component.despawn()
	else:
		var direction = global_transform.x.normalized()

		var collision_mask : int = 3
		var space_state := get_world_2d().direct_space_state
		var query := PhysicsRayQueryParameters2D.create(position, position + direction * speed * delta * margin, collision_mask)
		query.collide_with_areas = true
		var result := space_state.intersect_ray(query)
		if result.is_empty():
			position += direction * speed * delta
		else:
			var body : Node2D = result["collider"] as Node2D
			var damage_component: DamageComponent = body.get_parent().get_node_or_null("DamageComponent") as DamageComponent
			if damage_component != null:
				damage_component.take_damage()
			spawn_component.despawn()

func _on_spawned(spawn_component: SpawnComponent):
	time_alive = 0.0

func _on_despawned(spawn_component: SpawnComponent):
	pass
