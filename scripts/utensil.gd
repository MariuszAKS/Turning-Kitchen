class_name Utensil
extends StaticBody2D


@onready var ingredients_textures = load("res://art/visual/ingredients.png")
@onready var ingredients_prepared_textures = load("res://art/visual/ingredients_prepared.png")
@onready var pots_textures = load("res://art/visual/pots.png")

@export var utensil: Cooking.UtensilType
@onready var sprite: Sprite2D = get_node("Sprite")

var items = [null, null]
var item_types = [null, null]
# items[0] main slot: scrape, chop, mill, cook
# items[1] secondary: oven roasting

@onready var sprites: Array[Sprite2D] = [get_node("Sprite1"), get_node("Sprite2")]
@onready var timers: Array[Timer] = [get_node("Timer1"), get_node("Timer2")]
@onready var progress_bars: Array[TextureProgressBar] = [get_node("Progress1"), get_node("Progress2")]

# Submit, Chop, Scrape, Mill, SinkRunning, Sink, Oven, OvenRoast, OvenCook, OvenBoth
var utensil_functions: Array[Callable] = [
	submit, chop, scrape, mill
]


func _ready():
	sprite.frame = int(utensil)

	if utensil == Cooking.UtensilType.OVEN:
		sprites[0].texture = pots_textures
		sprites[0].frame = int(Cooking.Pot.EMPTY)
	else:
		sprites[0].texture = null
	
	sprites[1].texture = null

func _process(_delta):
	for i in range(2):
		if timers[i].time_left > 0:
			progress_bars[i].value = 100 - (timers[i].time_left / timers[i].wait_time) * 100


func on_interact(held_item, item_type):
	return utensil_functions[int(utensil)].call(held_item, item_type)


func take_item(id):
	var item_returned = items[id]
	var type_returned = item_types[0]
	
	progress_bars[id].value = 0
	put_item(null, null, id)

	return [item_returned, type_returned]

func put_item(item, item_type, id):
	items[id] = item
	item_types[id] = item_type

	if item == null: sprites[id].texture = null
	elif item is Cooking.Ingredient: sprites[id].texture = ingredients_textures
	elif item is Cooking.IngredientPrepared: sprites[id].texture = ingredients_prepared_textures
	elif item is Cooking.Pot: sprites[id].texture = pots_textures
	else: sprites[id].texture = null

func prepare_timer(result_item, item_type, id):
	timers[id].timeout.connect(func(): put_item(result_item, item_type, id))
	# turn on the preparing bar (set to 0)
	# I need it to observe the timer and update based on it


func submit(held_item, item_type):
	if held_item is Cooking.Dish:
		# count the dish as prepared
		return [null, null]
	return [held_item, item_type]

func chop(held_item, item_type):
	if held_item == null and items[0] != null:
		return take_item(0)

	elif held_item != null and items[0] == null:
		match item_type:
			Cooking.HeldItemType.INGREDIENT:
				if held_item == Cooking.Ingredient.TOMATO:
					prepare_timer(Cooking.IngredientPrepared.CHOPPED_TOMATO, Cooking.HeldItemType.INGREDIENT_PREPARED, 0)
				else:
					return [held_item, item_type]
			Cooking.HeldItemType.INGREDIENT_PREPARED:
				match held_item:
					Cooking.IngredientPrepared.SCRAPED_CARROT:
						prepare_timer(Cooking.IngredientPrepared.CHOPPED_CARROT, Cooking.HeldItemType.INGREDIENT_PREPARED, 0)
					Cooking.IngredientPrepared.SCRAPED_ONION:
						prepare_timer(Cooking.IngredientPrepared.CHOPPED_ONION, Cooking.HeldItemType.INGREDIENT_PREPARED, 0)
					Cooking.IngredientPrepared.SCRAPED_POTATO:
						prepare_timer(Cooking.IngredientPrepared.CHOPPED_POTATO, Cooking.HeldItemType.INGREDIENT_PREPARED, 0)
					_: return [held_item, item_type]
			_: return [held_item, item_type]

		timers[0].start(3)
		return [null, null]
	
	else: return [held_item, item_type]

func scrape(held_item, item_type):
	if held_item == null and items[0] != null:
		return take_item(0)

	elif held_item != null and items[0] == null:
		if item_type == Cooking.HeldItemType.INGREDIENT:
			match held_item:
				Cooking.Ingredient.CARROT:
					prepare_timer(Cooking.IngredientPrepared.SCRAPED_CARROT, Cooking.HeldItemType.INGREDIENT_PREPARED, 0)
				Cooking.Ingredient.ONION:
					prepare_timer(Cooking.IngredientPrepared.SCRAPED_ONION, Cooking.HeldItemType.INGREDIENT_PREPARED, 0)
				Cooking.Ingredient.POTATO:
					prepare_timer(Cooking.IngredientPrepared.SCRAPED_POTATO, Cooking.HeldItemType.INGREDIENT_PREPARED, 0)
				_: return [held_item, item_type]
		else:
			return [held_item, item_type]

		timers[0].start(3)
		return [null, null]
	
	else: return [held_item, item_type]

func mill(held_item, item_type):
	if held_item == null and items[0] != null:
		return take_item(0)

	elif items[0] == null and item_type == Cooking.HeldItemType.INGREDIENT_PREPARED and held_item == Cooking.IngredientPrepared.CHOPPED_TOMATO:
		prepare_timer(Cooking.IngredientPrepared.TOMATO_PASTE, Cooking.HeldItemType.INGREDIENT_PREPARED, 0)
		timers[0].start(3)

		return [null, null]
		
	return [held_item, item_type]
