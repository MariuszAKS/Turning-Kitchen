extends CharacterBody2D


const MOVEMENT_SPEED: float = 100

@export var interaction_raycast: RayCast2D
var held_item = null


func _ready():
    pass


func _process(_delta):
    var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")

    update_interaction_raycast(direction)

    if Input.is_action_just_pressed("interact"): interact()
    elif Input.is_action_just_pressed("drop"): drop()

    velocity = direction * MOVEMENT_SPEED
    move_and_slide()


func interact():
    print(interaction_raycast.get_collider())
    if interaction_raycast.is_colliding():
        pass
        # check for types of colliders (their scripts)

func drop():
    held_item = null


func update_interaction_raycast(direction: Vector2):
    if direction != Vector2.ZERO:
        if direction.x == 0:
            interaction_raycast.rotation_degrees = 0 if direction.y > 0 else 180
        elif direction.x > 0:
            interaction_raycast.rotation_degrees = 270 if direction.y == 0 else (315 if direction.y > 0 else 225)
        else:
            interaction_raycast.rotation_degrees = 90 if direction.y == 0 else (45 if direction.y > 0 else 135)
        
        # maybe later change to calculating the angle
