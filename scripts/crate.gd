class_name Crate
extends StaticBody2D


@onready var content_sprite: Sprite2D = get_node("ContentSprite")
@export var content: Cooking.Ingredient


func _ready():
    content_sprite.frame = int(content)

func on_interact() -> Cooking.Ingredient:
    return content
