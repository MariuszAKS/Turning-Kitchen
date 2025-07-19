extends StaticBody2D

enum UtensilType { Submit, Chop, Scrape, Empty, SinkRunning, Sink, Oven, OvenRoast, OvenCook, OvenBoth }


@onready var sprite: Sprite2D = get_node("Sprite")
@export var utensil: UtensilType


func _ready():
    sprite.frame = int(utensil)


func on_interact():
    pass
