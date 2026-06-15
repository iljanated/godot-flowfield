#include "igflowfield.h"
#include <godot_cpp/core/class_db.hpp>

using namespace godot;

void IGCostField::_bind_methods()
{
	ClassDB::bind_method(D_METHOD("set_map_size", "size"), &IGCostField::set_map_size);
	ClassDB::bind_method(D_METHOD("get_map_size"), &IGCostField::get_map_size);
	ClassDB::bind_method(D_METHOD("set_cost", "cost"), &IGCostField::set_cost);
	ClassDB::bind_method(D_METHOD("get_cost"), &IGCostField::get_cost);
	ClassDB::bind_method(D_METHOD("fill"), &IGCostField::fill);
	ClassDB::bind_method(D_METHOD("apply_falloff"), &IGCostField::apply_falloff);
}

void IGCostField::set_map_size(Vector2i p_size)
{
	map_size = p_size;
	size_t total_cells = static_cast<size_t>(map_size.x * map_size.y);
	costs.resize(total_cells);
}

Vector2i IGCostField::get_map_size() const
{
	return map_size;
}

void IGCostField::set_cost(int index, float value)
{
	costs[index] = value;
}

float IGCostField::get_cost(int index) const
{
	return costs[index];
}

void IGCostField::fill(float value)
{
	std::fill(costs.begin(), costs.end(), value);
}

void IGCostField::apply_falloff(float falloff, float falloff_start)
{
	// clear all previous falloffs

	for (size_t i = 0; i < costs.size(); ++i)
	{
		if (costs[i] < INFINITY)
		{
			costs[i] = 0.0f;
		}
	}

	int32_t width = map_size.x;
	int32_t height = map_size.y;
	int32_t total_cells = width * height;

	// Chamfer structures (hardcoded arrays for unrolling and cache optimization)
	const int32_t f_dx[4] = {-1, 0, -1, 1};
	const int32_t f_dy[4] = {0, -1, -1, -1};
	const float f_weight[4] = {1.0f, 1.0f, 1.41421356f, 1.41421356f};

	const int32_t b_dx[4] = {1, 0, 1, -1};
	const int32_t b_dy[4] = {0, 1, 1, 1};
	const float b_weight[4] = {1.0f, 1.0f, 1.41421356f, 1.41421356f};

	// 2. FORWARD PASS: From top-left to bottom-right
	for (int32_t y = 0; y < height; ++y)
	{
		int32_t row_offset = y * width;
		for (int32_t x = 0; x < width; ++x)
		{
			int32_t current_idx = row_offset + x;
			float current_val = costs[current_idx];

			if (current_val >= INFINITY)
				continue;

			float max_val = current_val;

			for (int32_t i = 0; i < 4; ++i)
			{
				int32_t nx = x + f_dx[i];
				int32_t ny = y + f_dy[i];

				if (nx >= 0 && nx < width && ny >= 0 && ny < height)
				{
					int32_t neighbor_idx = ny * width + nx;
					float neighbor_cost = costs[neighbor_idx];
					if (neighbor_cost > falloff_start)
					{
						neighbor_cost = falloff_start;
					}
					float val_through_neighbor = neighbor_cost - f_weight[i] * falloff;
					if (val_through_neighbor > max_val)
					{
						max_val = val_through_neighbor;
					}
				}
			}
			costs[current_idx] = max_val;
		}
	}

	// 3. BACKWARD PASS: From bottom-right to top-left
	for (int32_t y = height - 1; y >= 0; --y)
	{
		int32_t row_offset = y * width;
		for (int32_t x = width - 1; x >= 0; --x)
		{
			int32_t current_idx = row_offset + x;
			float current_val = costs[current_idx];

			if (current_val >= INFINITY)
				continue;

			float max_val = current_val;

			for (int32_t i = 0; i < 4; ++i)
			{
				int32_t nx = x + b_dx[i];
				int32_t ny = y + b_dy[i];

				if (nx >= 0 && nx < width && ny >= 0 && ny < height)
				{
					int32_t neighbor_idx = ny * width + nx;
					float neighbor_cost = costs[neighbor_idx];
					if (neighbor_cost > falloff_start)
					{
						neighbor_cost = falloff_start;
					}
					float val_through_neighbor = neighbor_cost - b_weight[i] * falloff;
					if (val_through_neighbor > max_val)
					{
						max_val = val_through_neighbor;
					}
				}
			}
			costs[current_idx] = max_val;
		}
	}
	UtilityFunctions::print("Falloff applied with falloff_Start: " + godot::String::num(falloff_start) + ", falloff: " + godot::String::num(falloff));
}

void IGFlowField::_bind_methods()
{
	ClassDB::bind_method(D_METHOD("set_map_size", "size"), &IGFlowField::set_map_size);
	ClassDB::bind_method(D_METHOD("get_map_size"), &IGFlowField::get_map_size);
	ClassDB::bind_method(D_METHOD("get_gradient", "position"), &IGFlowField::get_gradient);
	ClassDB::bind_method(D_METHOD("get_result_field"), &IGFlowField::get_result_field);
	ClassDB::bind_method(D_METHOD("calculate_field", "cost_fields", "target_indices"), &IGFlowField::calculate_field);
	ClassDB::bind_method(D_METHOD("get_is_calculating"), &IGFlowField::get_is_calculating);

	ADD_SIGNAL(MethodInfo("calculation_done"));
}

IGFlowField::IGFlowField()
{
	// Initialize any variables here.
}

IGFlowField::~IGFlowField()
{
	// Add your cleanup here.
}

void IGFlowField::set_map_size(Vector2i p_size)
{
	if (is_calculating.load())
	{
		UtilityFunctions::push_warning("Cannot change map size while calculation is in progress.");
		return;
	}

	map_size = p_size;
	size_t total_cells = static_cast<size_t>(map_size.x * map_size.y);

	// Reserveren van geheugen vooraf zodat dit niet tijdens het berekenen gebeurt
	field_buffer.resize(total_cells);
	result_field.resize(total_cells);
}

Vector2i IGFlowField::get_map_size() const
{
	return map_size;
}

bool IGFlowField::get_is_calculating() const
{
	return is_calculating.load();
}

Vector2 IGFlowField::get_gradient(Vector2i position) const
{
	if (map_size.x == 0 || map_size.y == 0)
	{
		UtilityFunctions::push_warning("Map size is not set. Cannot get gradient.");
		return Vector2(0, 0);
	}

	int index = position.x + position.y * map_size.x;
	if (index < 0 || index >= static_cast<int>(result_field.size()))
	{
		UtilityFunctions::push_warning("Position out of bounds. Cannot get gradient.");
		return Vector2(0, 0);
	}
	float center = result_field[index];
	float left = (position.x > 0) ? result_field[index - 1] : center;
	if (left == INFINITY)
	{
		left = center;
	}
	float right = (position.x < map_size.x - 1) ? result_field[index + 1] : center;
	if (right == INFINITY)
	{
		right = center;
	}
	float up = (position.y > 0) ? result_field[index - map_size.x] : center;
	if (up == INFINITY)
	{
		up = center;
	}
	float down = (position.y < map_size.y - 1) ? result_field[index + map_size.x] : center;
	if (down == INFINITY)
	{
		down = center;
	}

	return Vector2(left - right, up - down).normalized();
}

PackedFloat32Array IGFlowField::get_result_field() const
{
	PackedFloat32Array output;
	output.resize(result_field.size());

	float *write_ptr = output.ptrw();
	std::copy(result_field.begin(), result_field.end(), write_ptr);

	return output;
}

void IGFlowField::calculate_field(Array cost_fields, PackedInt32Array target_indices)
{
	bool expected = false;
	if (!is_calculating.compare_exchange_strong(expected, true))
	{
		UtilityFunctions::push_warning("Calculation ignored: MapProcessor is already calculating a field.");
		return;
	}

	size_t total_cells = static_cast<size_t>(map_size.x * map_size.y);
	if (total_cells == 0)
	{
		UtilityFunctions::push_warning("Map size is not set. Cannot calculate field.");
		is_calculating.store(false);
		return;
	}

	// 1. Vul de actieve rekenbuffer met 'Infinity'
	std::fill(field_buffer.begin(), field_buffer.end(), INFINITY);

	const int32_t *targets_read = target_indices.ptr();
	int target_count = target_indices.size();

	// Snelle hash-set voor O(1) lookups
	std::unordered_set<int32_t> target_set;
	target_set.reserve(target_count);

	// 2. Zet targets op 0.0 in de buffer
	for (int i = 0; i < target_count; ++i)
	{
		int32_t idx = targets_read[i];
		if (idx >= 0 && idx < static_cast<int32_t>(total_cells))
		{
			field_buffer[idx] = 0.0f;
			target_set.insert(idx);
		}
	}

	// Cache CostFields lokaal om pointer-chasing in de geneste lussen te voorkomen
	struct CachedCostField
	{
		const float *costs_ptr;
		float multiplier;
		bool is_boolean;
	};

	std::vector<const float *> cached_costs;
	cached_costs.reserve(cost_fields.size());
	for (int i = 0; i < cost_fields.size(); ++i)
	{
		Ref<IGCostField> cf = cost_fields[i];
		if (cf.is_valid())
		{
			cached_costs.push_back(cf->costs.ptr());
		}
	}

	// 3. Multi-directionele sweeps definiëren
	struct Sweep
	{
		int x_start, x_end, x_step;
		int y_start, y_end, y_step;
	};

	std::vector<Sweep> sweeps = {
		{0, map_size.x, 1, 0, map_size.y, 1},
		{0, map_size.x, 1, map_size.y - 1, -1, -1},
		{map_size.x - 1, -1, -1, 0, map_size.y, 1},
		{map_size.x - 1, -1, -1, map_size.y - 1, -1, -1}};

	// 4. Rekenlussen uitvoeren op 'field_buffer'
	for (int iter = 0; iter < iterations; ++iter)
	{
		for (const auto &sweep : sweeps)
		{

			for (int x = sweep.x_start; sweep.x_step > 0 ? x < sweep.x_end : x > sweep.x_end; x += sweep.x_step)
			{
				for (int y = sweep.y_start; sweep.y_step > 0 ? y < sweep.y_end : y > sweep.y_end; y += sweep.y_step)
				{

					int idx = y * map_size.x + x;

					if (target_set.find(idx) != target_set.end())
					{
						continue;
					}

					float slowness = 1.0f;

					for (const auto &costs_ptr : cached_costs)
					{
						slowness += costs_ptr[idx];
					}

					// Get values of 4-connected neighbors, default to INFINITY if out of bounds
					float u_xmin = (x > 0) ? field_buffer[idx - 1] : INFINITY;
					float u_xmax = (x < map_size.x - 1) ? field_buffer[idx + 1] : INFINITY;
					float u_ymin = (y > 0) ? field_buffer[idx - map_size.x] : INFINITY;
					float u_ymax = (y < map_size.y - 1) ? field_buffer[idx + map_size.x] : INFINITY;

					// Choose the minimum neighbor value along each axis
					float u_x = std::min(u_xmin, u_xmax);
					float u_y = std::min(u_ymin, u_ymax);

					float u_min = std::min(u_x, u_y);
					float u_max = std::max(u_x, u_y);

					// f_inv represents the cost to travel across this specific cell
					// Derived from: slowness * grid_spacing (h)
					float f_inv = slowness;
					float u_new = INFINITY;

					if (u_max == INFINITY || (u_max - u_min) >= f_inv)
					{
						// 1D Update: Wavefront travels strictly along one dominant axis
						u_new = u_min + f_inv;
					}
					else
					{
						// 2D Update: Wavefront crosses the cell diagonally
						float diff = u_x - u_y;
						u_new = 0.5f * ((u_x + u_y) + std::sqrt(2.0f * f_inv * f_inv - diff * diff));
					}

					// Maintain the viscosity solution (keep the minimum arrival time)
					if (u_new < field_buffer[idx])
					{
						field_buffer[idx] = u_new;
					}
				}
			}
		}
	}

	std::swap(result_field, field_buffer);
	is_calculating.store(false);
	emit_signal("calculation_done");
}