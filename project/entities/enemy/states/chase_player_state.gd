extends State
class_name ChasePlayerState

@export var character_body : CharacterBody2D
@export var walk_component : WalkComponent
var map : Map

func enter():
    print("Entering ChasePlayerState")
    map = get_tree().root.get_node("Level/Map")
    print("Map found: ", map != null)

func exit():
    map = null

func update(delta):
    pass

func physics_update(delta):
    if map != null:
        var gradient = map.get_gradient("player", character_body.position)
        walk_component.direction = gradient

