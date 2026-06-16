extends Area2D
class_name Exit

func _on_area_2d_body_entered(body: Node) -> void:
	var exit_component: ExitComponent = body.get_node_or_null("ExitComponent") as ExitComponent
	if exit_component != null:
		exit_component.on_exit_reached()
