extends Marker2D
class_name Spawner

var _spawn_pools : Dictionary[String, SpawnPool] = {}

func _ready() -> void:
	WorldSignals.spawn.connect(_on_spawn)

func _on_spawn(scene_name: String, target_transform: Transform2D, resource: String) -> void:
	var spawn_pool: SpawnPool = _spawn_pools.get(scene_name, null)
	if spawn_pool == null:
		spawn_pool = SpawnPool.new()
		add_child(spawn_pool)
		_spawn_pools[scene_name] = spawn_pool
	spawn_pool.spawn(scene_name, target_transform, resource)
