extends Node

class_name StateMachine

@export var initial_state : State

var current_state : State = null
var states : Dictionary = {}

func _ready():
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.transitioned.connect(_on_state_transitioned)

	print("States found: ", states.keys())
	if initial_state:
		print("Initial state: ", initial_state.name)
		initial_state.enter()
		current_state = initial_state

func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)

func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)

func _on_state_transitioned(state: State, new_state_name: String) -> void:
	if state != current_state:
		return

	
	var new_state = states.get(new_state_name.to_lower(), null)
	
	if !new_state:
		print("State not found: ", new_state_name)
		return

	if current_state:
		current_state.exit()
	
	new_state.enter()

	current_state = new_state