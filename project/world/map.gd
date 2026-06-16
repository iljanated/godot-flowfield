extends Node2D
class_name Map

@export var subdivisions: int = 2
@export var player: Node2D
@export var block_cost: float = INF
@export var block_falloff_start: float = 1.0
@export var block_falloff: float = 0.3

@export var player_walk_flowfield: FlowField
@export var exit0_walk_flowfield: FlowField
@export var exit1_walk_flowfield: FlowField

@export var exit0 : Node2D
@export var exit1 : Node2D

var layers_rect: Rect2i
var map_size: Vector2i = Vector2i(0, 0)
var tile_size: Vector2i

var _blockers_costfield: IGCostField
var _walkers_costfield: IGCostField

var _world_to_map_transform: Transform2D
var _map_to_world_transform: Transform2D
var _map_to_world_direction_transform: Transform2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_init_map()

func _physics_process(delta: float) -> void:

	_update_dynamic_costfields()

	var cost_fields: Array[IGCostField] = [_blockers_costfield, _walkers_costfield]

	if player != null:
		var player_map_position = _world_to_map_transform * player.position
		var index = int(player_map_position.y) * map_size.x + int(player_map_position.x)
		player_walk_flowfield.calculate_field(cost_fields, [index])

	var exit0_map_position = _world_to_map_transform * exit0.position
	var index0 = int(exit0_map_position.y) * map_size.x + int(exit0_map_position.x)
		
	exit0_walk_flowfield.calculate_field(cost_fields, [index0])

	var exit1_map_position = _world_to_map_transform * exit1.position
	var index1 = int(exit1_map_position.y) * map_size.x + int(exit1_map_position.x)

	exit1_walk_flowfield.calculate_field(cost_fields, [index1])
	
		
func _draw() -> void:
	#var result_field: PackedFloat32Array = flowfield.get_result_field()
	
	# var default_font: Font = ThemeDB.fallback_font;
	for y in map_size.y:
		for x in map_size.x:
			var pos = _map_to_world_transform * Vector2(x, y)
			var cost = _walkers_costfield.get_cost(y * map_size.x + x)

			#var distance = result_field[y * map_size.x + x]

			if cost > 0.0:
				draw_circle(pos, 2, Color(1, 0, 0))
				# draw_string(default_font, pos, str(cost).pad_decimals(1), HORIZONTAL_ALIGNMENT_CENTER, 32, 10,Color(0, 0, 1))
			#draw_string(default_font, pos, str(distance).pad_decimals(1), HORIZONTAL_ALIGNMENT_CENTER, 32, 10,Color(0, 0, 1))


func _init_map() -> void:
	await get_tree().physics_frame
	await get_tree().physics_frame
	_init_dimensions()
	_init_transforms()
	_init_static_costs()
	_init_dynamic_costs()
	_init_flowfields()
	queue_redraw()

func _init_dimensions() -> void:
	var root_node: Window = get_tree().root
	var tilemap_layers: Array[Node] = root_node.find_children("*", "TileMapLayer", true, false)
	for layer_node in tilemap_layers:
		var layer: TileMapLayer = layer_node as TileMapLayer
		print("Processing layer: ", layer.name)
		if not layers_rect:
			layers_rect = layer.get_used_rect()
		else:
			layers_rect = layers_rect.merge(layer.get_used_rect())
		if not tile_size:
			tile_size = layer.tile_set.tile_size

	map_size = layers_rect.size * subdivisions

	print ("Layers rect: ", layers_rect)
	print ("Tile size: ", tile_size)
	print ("Map size: ", map_size)

func _init_transforms() -> void:
	var map_to_total = Transform2D(
		Vector2(1.0 / subdivisions, 0.0),
		Vector2(0.0, 1.0 / subdivisions),
		Vector2(
			layers_rect.position.x + (1.0 - 0.5 / subdivisions),
			layers_rect.position.y - 0.5 / subdivisions
		)
	)

	var total_to_world = Transform2D(
		Vector2(tile_size.x / 2.0, tile_size.y / 2.0),
		Vector2(-tile_size.x / 2.0, tile_size.y / 2.0),
		Vector2.ZERO
	)

	_map_to_world_transform = total_to_world * map_to_total
	_world_to_map_transform = _map_to_world_transform.affine_inverse()
	_map_to_world_direction_transform = Transform2D(_map_to_world_transform.x, _map_to_world_transform.y, Vector2.ZERO)

	player_walk_flowfield.map_to_world = _map_to_world_transform
	exit0_walk_flowfield.map_to_world = _map_to_world_transform
	exit1_walk_flowfield.map_to_world = _map_to_world_transform

func _init_static_costs() -> void:
	_blockers_costfield = IGCostField.new()
	_blockers_costfield.set_map_size(map_size)
	_blockers_costfield.fill(0)
	
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.collide_with_areas = false
	query.collide_with_bodies = true
	query.collision_mask = 1

	for y in map_size.y:
		for x in map_size.x:
			var world_position = _map_to_world_transform * Vector2(x, y)
			query.position = world_position
			var results = space_state.intersect_point(query, 1)
			if (results.size() > 0):
				_blockers_costfield.set_cost(y * map_size.x + x, block_cost)
	
	_blockers_costfield.apply_falloff(block_falloff, block_falloff_start, INF)

	print("Blockers initialized")

func _init_dynamic_costs() -> void:
	_walkers_costfield = IGCostField.new()
	_walkers_costfield.set_map_size(map_size)
	_walkers_costfield.fill(0)
	print("Dynamic lockers initialized")

func _update_dynamic_costfields() -> void:
	if _walkers_costfield == null:
		return
	_walkers_costfield.fill(0)
	var walkers: Array[Node] = get_tree().get_nodes_in_group("walkers")
	for walker in walkers:
		var walker_map_position = _world_to_map_transform * walker.position
		var index = int(walker_map_position.y) * map_size.x + int(walker_map_position.x)
		_walkers_costfield.set_cost(index, 1.0)
	_walkers_costfield.apply_falloff(0.3, 1.2, 1.0)

func _init_flowfields() -> void:
	var cost_fields: Array[IGCostField] = [_blockers_costfield, _walkers_costfield]

	player_walk_flowfield.calculation_done.connect(_on_flowfield_updated)
	player_walk_flowfield.set_map_size(map_size)
	player_walk_flowfield.calculate_field(cost_fields, [0])

	exit0_walk_flowfield.calculation_done.connect(_on_flowfield_updated)
	exit0_walk_flowfield.set_map_size(map_size)
	exit0_walk_flowfield.calculate_field(cost_fields, [0])

	exit1_walk_flowfield.calculation_done.connect(_on_flowfield_updated)
	exit1_walk_flowfield.set_map_size(map_size)
	exit1_walk_flowfield.calculate_field(cost_fields, [0])

func _on_flowfield_updated() -> void:
	pass

func get_gradient(target: String, world_position: Vector2) -> Vector2:
	var flowfield : FlowField
	
	match target:
		"player":
			flowfield = player_walk_flowfield
		"exit0":
			flowfield = exit0_walk_flowfield
		"exit1":
			flowfield = exit1_walk_flowfield
		_:
			return Vector2.ZERO
	
	var map_position : Vector2i = _world_to_map_transform * world_position
	return (_map_to_world_direction_transform * flowfield.get_gradient(map_position)).normalized()
