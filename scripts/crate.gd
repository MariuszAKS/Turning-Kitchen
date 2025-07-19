extends Node2D

enum Ingredient { Carrot, Onion, Potato, Tomato, Rice, Beans, Beef, Chicken }


@onready var content_sprite: Sprite2D = get_node("ContentSprite")
@export var content: Ingredient


func _ready():
    content_sprite.frame = int(content)
