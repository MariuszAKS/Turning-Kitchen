extends CharacterBody2D


const MOVEMENT_SPEED: float = 100

@onready var animations: AnimatedSprite2D = get_node("Animations")
@onready var interaction_raycast: RayCast2D = get_node("InteractionRaycast")

var previous_direction: Vector2 = Vector2.ZERO
var held_item = null


func _process(_delta):
    var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")

    update_animation(direction)
    update_interaction_raycast(direction)

    if Input.is_action_just_pressed("interact"): interact()
    elif Input.is_action_just_pressed("drop"): drop()

    previous_direction = direction
    velocity = direction * MOVEMENT_SPEED
    move_and_slide()


func interact():
    print(interaction_raycast.get_collider())
    if interaction_raycast.is_colliding():
        pass
        # check for types of colliders (their scripts)

func drop():
    held_item = null


func update_animation(direction: Vector2):
    if direction == Vector2.ZERO:
        if animations.is_playing():
            animations.stop()
    else:
        if not animations.is_playing() or direction != previous_direction:
            if direction.y == 0:
                animations.play("walk_right" if direction.x > 0 else "walk_left")
            else:
                animations.play("walk_down" if direction.y > 0 else "walk_up")


func update_interaction_raycast(direction: Vector2):
    if direction != Vector2.ZERO:
        if direction.x == 0:
            interaction_raycast.rotation_degrees = 0 if direction.y > 0 else 180
        elif direction.x > 0:
            interaction_raycast.rotation_degrees = 270 if direction.y == 0 else (315 if direction.y > 0 else 225)
        else:
            interaction_raycast.rotation_degrees = 90 if direction.y == 0 else (45 if direction.y > 0 else 135)
        
        # maybe later change to calculating the angle
