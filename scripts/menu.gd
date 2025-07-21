extends Control


@export var button_start: Button
@export var button_stats: Button

@export var statistics: Control


func _ready():
    button_start.pressed.connect(start_game)
    button_stats.pressed.connect(show_statistics)
    
    statistics.visible = false

func start_game():
    get_tree().change_scene_to_file("res://scenes/world.tscn")

func show_statistics():
    statistics.visible = true
