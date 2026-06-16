extends Node2D
class_name SpawnPool

var _scene : PackedScene = null
var _spawn_components : Array[SpawnComponent] = []

func _ready() -> void:
	y_sort_enabled = true

func spawn(scene_name: String, target_transform: Transform2D, resource: String) -> void:
	var spawn_component: SpawnComponent = null
	var instance: Node2D = null
	for i in range(_spawn_components.size()):
		var next_component: SpawnComponent = _spawn_components[i]
		if next_component.can_spawn:
			spawn_component = next_component
			instance = spawn_component.get_parent() as Node2D
			print("SpawnPool: Reusing existing instance of ", scene_name, " at index ", i)
			break
	if spawn_component == null:
		if _scene == null:
			_scene = load("res://entities/enemy/enemy.tscn") as PackedScene
		instance = _scene.instantiate()
		instance.add_to_group("walkers")
		add_child(instance)
		spawn_component = instance.get_node_or_null("SpawnComponent") as SpawnComponent
		if spawn_component == null:
			push_error("SpawnPool: Spawned scene does not have a SpawnComponent.")
			instance.queue_free()
			return
		spawn_component.despawned.connect(_on_spawn_component_despawned)
		_spawn_components.append(spawn_component)
	
	spawn_component.can_spawn = false
	instance.global_transform = target_transform
	instance.set_process(true)
	instance.set_physics_process(true)
	instance.show()
	spawn_component.on_spawn()

func _on_spawn_component_despawned(spawn_component: SpawnComponent) -> void:
	var instance: Node2D = spawn_component.get_parent() as Node2D
	instance.set_process(false)
	instance.set_physics_process(false)
	instance.hide()
	instance.global_position = global_position
	spawn_component.can_spawn = true
