class_name World
extends Node2D


@export var menu: Control
var start_screen: VBoxContainer
# var pause_screen: VBoxContainer
var day_won_screen: VBoxContainer
var day_lost_screen: VBoxContainer

var start_game_button_1: Button
var start_game_button_2: Button
# var unpause_button: Button
var next_day_button: Button

var survived_label: Label
var death_label: Label

@export var timer: Timer
@export var timer_label: Label
var dish_left_counts: Array[Label] = []
var time_multiplier = 2

var current_day = 0
var current_goals = { Cooking.Dish.BEANS_RICE: 0, Cooking.Dish.CHICKEN_SOUP: 0, Cooking.Dish.BEEF_POTATOES: 0, Cooking.Dish.TOMATO_SOUP: 0 }


func _ready():
	start_screen = menu.get_node("CenterContainer/StartScreen")
	# pause_screen = menu.get_node("CenterContainer/PauseScreen")
	day_won_screen = menu.get_node("CenterContainer/DayWonScreen")
	day_lost_screen = menu.get_node("CenterContainer/DayLostScreen")

	start_game_button_1 = start_screen.get_node("StartGameButton")
	start_game_button_2 = day_lost_screen.get_node("StartGameButton")
	# unpause_button = pause_screen.get_node("UnpauseButton")
	next_day_button = day_won_screen.get_node("NextDayButton")

	start_game_button_1.pressed.connect(start_new_game)
	start_game_button_2.pressed.connect(start_new_game)
	# unpause_button.pressed.connect(unpause_game)
	next_day_button.pressed.connect(start_next_day)

	timer.timeout.connect(on_timer_timeout)

	dish_left_counts = [
		get_node("UI/DishLabel1"),
		get_node("UI/DishLabel2"),
		get_node("UI/DishLabel3"),
		get_node("UI/DishLabel4"),
	]
	
	menu.visible = true
	start_screen.visible = true
	# pause_screen.visible = false
	day_won_screen.visible = false
	day_lost_screen.visible = false

func _process(_delta):
	# if menu.visible == false and Input.is_action_just_pressed("pause"): pause_game()

	timer_label.text = str(int(timer.time_left))


func start_new_game():
	menu.visible = false

	time_multiplier = 2
	current_day = 0

	update_current_goals()
	timer.start()

func start_next_day():
	menu.visible = false

	current_day += 1

	update_current_goals()
	timer.start()

# func pause_game():
# 	get_tree().paused = true

# 	menu.visible = true
# 	start_screen.visible = false
# 	pause_screen.visible = true
# 	day_won_screen.visible = false
# 	day_lost_screen.visible = false

# func unpause_game():
# 	get_tree().paused = false
# 	menu.visible = false


func update_current_goals():
	if current_day < 7:
		current_goals[Cooking.Dish.BEANS_RICE] = Cooking.first_goals[current_day][Cooking.Dish.BEANS_RICE]
		current_goals[Cooking.Dish.CHICKEN_SOUP] = Cooking.first_goals[current_day][Cooking.Dish.CHICKEN_SOUP]
		current_goals[Cooking.Dish.BEEF_POTATOES] = Cooking.first_goals[current_day][Cooking.Dish.BEEF_POTATOES]
		current_goals[Cooking.Dish.TOMATO_SOUP] = Cooking.first_goals[current_day][Cooking.Dish.TOMATO_SOUP]
	else:
		clear_current_goals()
		randomize_dishes()
		time_multiplier -= 0.05
	
	update_dish_labels()
	calculate_time()

func clear_current_goals():
	current_goals[Cooking.Dish.BEANS_RICE] = 0
	current_goals[Cooking.Dish.CHICKEN_SOUP] = 0
	current_goals[Cooking.Dish.BEEF_POTATOES] = 0
	current_goals[Cooking.Dish.TOMATO_SOUP] = 0

func randomize_dishes():
	for i in range(10):
		current_goals[(randi() % 4) as Cooking.Dish] += 1

func calculate_time():
	var time = 0

	for i in range(4):
		time += current_goals[i as Cooking.Dish] * Cooking.times[i as Cooking.Dish]
	
	timer.wait_time = time * time_multiplier


func submited_dish(dish: Cooking.Dish):
	if current_goals[dish] > 0:
		current_goals[dish] -= 1
	
	update_dish_labels()

	if check_goals_completion():
		completed_all_goals()

func update_dish_labels():
	dish_left_counts[0].text = str(current_goals[Cooking.Dish.BEANS_RICE])
	dish_left_counts[1].text = str(current_goals[Cooking.Dish.CHICKEN_SOUP])
	dish_left_counts[2].text = str(current_goals[Cooking.Dish.BEEF_POTATOES])
	dish_left_counts[3].text = str(current_goals[Cooking.Dish.TOMATO_SOUP])

func check_goals_completion():
	var no_bean_rice = current_goals[Cooking.Dish.BEANS_RICE] == 0
	var no_chicken_soup = current_goals[Cooking.Dish.CHICKEN_SOUP] == 0
	var no_beef_potatoes = current_goals[Cooking.Dish.BEEF_POTATOES] == 0
	var no_tomato_soup = current_goals[Cooking.Dish.TOMATO_SOUP] == 0

	return no_bean_rice and no_chicken_soup and no_beef_potatoes and no_tomato_soup


func completed_all_goals():
	timer.stop()

	menu.visible = true
	start_screen.visible = false
	# pause_screen.visible = false
	day_won_screen.visible = true
	day_lost_screen.visible = false

	survived_label.text = "You lived ${current_day+1} so far.\nContinue?"


func on_timer_timeout():
	menu.visible = true
	start_screen.visible = false
	# pause_screen.visible = false
	day_won_screen.visible = false
	day_lost_screen.visible = true

	death_label.text = "You died after ${current_day} days.\nTry again?"
