extends AnimatedSprite2D

@export var damage_interval: float = 0.3

var overlapping_damage_components: Array[DamageComponent] = []

@onready var timer: Timer = $Timer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer.wait_time = damage_interval

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_area_2d_area_exited(area: Node2D) -> void:
	var damage_component: DamageComponent = area.get_parent().get_node_or_null("DamageComponent") as DamageComponent
	if damage_component != null:
		overlapping_damage_components.erase(damage_component)
		if overlapping_damage_components.size() == 0:
			timer.stop()

func _on_area_2d_area_entered(area: Node2D) -> void:
	var damage_component: DamageComponent = area.get_parent().get_node_or_null("DamageComponent") as DamageComponent
	if damage_component != null:
		overlapping_damage_components.append(damage_component)
		if overlapping_damage_components.size() == 1:
			timer.start()

func _on_timer_timeout() -> void:
	if overlapping_damage_components.size() > 0:
		for damage_component in overlapping_damage_components:
			damage_component.take_damage()