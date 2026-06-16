#pragma once

#include <godot_cpp/classes/node2d.hpp>
#include <godot_cpp/classes/ref_counted.hpp>
#include <godot_cpp/variant/vector2i.hpp>
#include <godot_cpp/variant/array.hpp>
#include <godot_cpp/variant/packed_float32_array.hpp>
#include <godot_cpp/variant/packed_int32_array.hpp>
#include <vector>
#include <cmath>
#include <algorithm>
#include <atomic> // Toegevoegd voor thread-safe checks

namespace godot {

class IGCostField : public RefCounted {
    GDCLASS(IGCostField, RefCounted);
private:
	Vector2i map_size = Vector2i(0, 0);
protected:
    static void _bind_methods();
public:
	void set_map_size(Vector2i p_size);
    Vector2i get_map_size() const;
	void set_cost(int index, float value);
	float get_cost(int index) const;
	void fill(float value);
	void apply_falloff(float falloff, float falloff_start, float max_value);
	
	PackedFloat32Array costs;
};


enum FMMState : uint8_t {
    FAR = 0,
    CONSIDERED = 1,
    ACCEPTED = 2
};

// Element struct for the custom min-heap
struct FMMElement {
    int idx;
    float value;
};

// Comparator for min-heap (lowest value bubbles to the top)
auto fmm_compare = [](const FMMElement& a, const FMMElement& b) {
    return a.value > b.value;
};

class IGFlowField : public Node2D {
	GDCLASS(IGFlowField, Node2D)

private:
	int iterations = 2;
    Vector2i map_size = Vector2i(0, 0);
	std::atomic<bool> is_calculating{false};
	std::vector<float> field_buffer;
    std::vector<float> result_field;
    // Persistent buffers to eliminate runtime heap allocations
    std::vector<uint8_t> cell_states;
    std::vector<const float*> cached_costs;
    std::vector<FMMElement> open_set; // Replaces std::priority_queue smoothly
protected:
	static void _bind_methods();

public:
	IGFlowField();
	~IGFlowField();

	void set_map_size(Vector2i p_size);
    Vector2i get_map_size() const;
    Vector2 get_gradient(Vector2i position) const;
	PackedFloat32Array get_result_field() const;
    void calculate_field(Array cost_fields, PackedInt32Array target_indices);
	bool get_is_calculating() const;
};

} // namespace godot