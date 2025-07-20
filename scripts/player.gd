extends CharacterBody2D


const MOVEMENT_SPEED: float = 100

@onready var animations: AnimatedSprite2D = get_node("Animations")
var previous_direction: Vector2 = Vector2.ZERO

@onready var interaction_raycast: RayCast2D = get_node("InteractionRaycast")
@onready var ingredients_textures = load("res://art/visual/ingredients.png")
@onready var ingredients_prepared_textures = load("res://art/visual/ingredients_prepared.png")
@onready var pots_textures = load("res://art/visual/pots.png")
@onready var dishes_textures = load("res://art/visual/dishes.png")
@export var held_item_sprite: Sprite2D
var held_item_type = null
var held_item = null


func _process(_delta):
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")

	update_animation(direction)
	update_interaction_raycast(direction)

	if Input.is_action_just_pressed("pause"): pass
	elif Input.is_action_just_pressed("goal_list"): pass
	elif Input.is_action_just_pressed("interact"): interact()
	elif Input.is_action_just_pressed("drop"): drop()

	previous_direction = direction
	velocity = direction * MOVEMENT_SPEED
	move_and_slide()


func interact(): # Not finished with utensils
	if interaction_raycast.is_colliding():
		var collider = interaction_raycast.get_collider()

		if collider is Crate:
			update_held_item((collider as Crate).on_interact(), Cooking.HeldItemType.INGREDIENT)
		elif collider is Utensil:
			var result = (collider as Utensil).on_interact(held_item, held_item_type)
			update_held_item(result[0], result[1])

func drop():
	update_held_item(null, null)


func update_held_item(new_item, item_type):
	held_item = new_item
	held_item_type = item_type

	if new_item == null:
		held_item_sprite.texture = null
	else:
		match item_type:
			Cooking.HeldItemType.INGREDIENT:
				held_item_sprite.texture = ingredients_textures
				held_item_sprite.hframes = 8
			Cooking.HeldItemType.INGREDIENT_PREPARED:
				held_item_sprite.texture = ingredients_prepared_textures
				held_item_sprite.hframes = 13
			Cooking.HeldItemType.POT:
				held_item_sprite.texture = pots_textures
				held_item_sprite.hframes = 17
			Cooking.HeldItemType.DISH:
				held_item_sprite.texture = dishes_textures
				held_item_sprite.hframes = 4
			_:
				held_item_sprite.texture = pots_textures
				held_item_sprite.frame = int(Cooking.Pot.WATER_BOILING) # Shouldn't be able to acquire it, so use as error
				return
		
		held_item_sprite.frame = int(new_item)


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
