extends IGFlowField

class_name FlowField

var map_to_world: Transform2D = Transform2D.IDENTITY

var _line_points: PackedVector2Array = []
var _line_colors: PackedColorArray = []

func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	# Draw the flow field vectors

	var map_size = get_map_size()
	var total_cells = map_size.x * map_size.y
	if _line_points.size() != total_cells * 4:
		_line_points.resize(total_cells * 4)
		_line_colors.resize(total_cells * 2)

	if map_size == Vector2i.ZERO:
		return

	var idx: int = 0
	var blue_color := Color(0, 0, 1)
	var red_color := Color(1, 0, 0)

	for y in map_size.y:
		for x in map_size.x:
			var map_start = Vector2(x, y)
			var gradient = get_gradient(Vector2i(x, y))
			var half_dir : Vector2 = gradient * 0.5
			
			var start = map_start
			var mid : Vector2 = map_start + half_dir
			var segment_end : Vector2 = map_start + half_dir * 1.4
			
			# Blauw segment
			_line_points[idx] = start
			_line_points[idx + 1] = mid
			_line_colors[idx / 2] = blue_color
			
			# Rood segment
			_line_points[idx + 2] = mid
			_line_points[idx + 3] = segment_end
			_line_colors[idx * 0.5 + 1] = red_color
			
			idx += 4
	draw_set_transform_matrix(map_to_world)
	draw_multiline_colors(_line_points, _line_colors)
	draw_set_transform_matrix(Transform2D.IDENTITY)
