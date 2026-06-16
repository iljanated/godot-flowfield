extends State
class_name GoToExitState

@onready var character_body : CharacterBody2D = $"../.."
@onready var walk_component : WalkComponent = $"../../WalkComponent"

var exit_name : String = "exit0"
var map : Map

func enter():
	print("Entering GoToExitState")
	map = get_tree().root.get_node("Level/Map")
	print("Map found: ", map != null)

func exit():
	map = null

func update(delta):
	pass

func physics_update(delta):
	if map != null:
		var gradient = map.get_gradient(exit_name, character_body.position)
		walk_component.direction = gradient
