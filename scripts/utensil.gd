class_name Utensil
extends StaticBody2D


@onready var ingredients_textures = load("res://art/visual/ingredients.png")
@onready var ingredients_prepared_textures = load("res://art/visual/ingredients_prepared.png")
@onready var pots_textures = load("res://art/visual/pots.png")

@export var utensil: Cooking.UtensilType
@export var start_with_pot: bool
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
	submit, chop, scrape, mill, sink, sink, oven, oven, oven, oven
]


func _ready():
	update_utensil(utensil)

	if utensil == Cooking.UtensilType.OVEN and start_with_pot:
		items[0] = Cooking.Pot.EMPTY
		item_types[0] = Cooking.HeldItemType.POT

		sprites[0].texture = pots_textures
		sprites[0].frame = int(Cooking.Pot.EMPTY)
	else:
		sprites[0].texture = null
	
	sprites[1].texture = null

func _process(_delta):
	for i in range(2):
		if timers[i].time_left > 0:
			progress_bars[i].value = 100 - (timers[i].time_left / timers[i].wait_time) * 100

func update_utensil(new_utensil):
	utensil = new_utensil
	sprite.frame = int(new_utensil)


func on_interact(held_item, item_type):
	return utensil_functions[int(utensil)].call(held_item, item_type)


func take_item(id):
	var item_returned = items[id]
	var type_returned = item_types[id]
	
	progress_bars[id].value = 0
	put_item(null, null, id)

	return [item_returned, type_returned]

func put_item(item, item_type, id):
	items[id] = item
	item_types[id] = item_type

	if item == null:
		sprites[id].texture = null
		return
	
	sprites[id].frame = int(item)

	match item_type:
		Cooking.HeldItemType.INGREDIENT:
			sprites[id].texture = ingredients_textures
			sprites[id].hframes = 8
		Cooking.HeldItemType.INGREDIENT_PREPARED:
			sprites[id].texture = ingredients_prepared_textures
			sprites[id].hframes = 13
		Cooking.HeldItemType.POT:
			sprites[id].texture = pots_textures
			sprites[id].hframes = 18
		_:
			sprites[id].texture = null


func prepare_timer(result_item, item_type, id, time):
	timers[id].timeout.connect(func(): put_item(result_item, item_type, id))
	timers[id].start(time)


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
					prepare_timer(Cooking.IngredientPrepared.CHOPPED_TOMATO, Cooking.HeldItemType.INGREDIENT_PREPARED, 0, 3)
				else:
					return [held_item, item_type]
			Cooking.HeldItemType.INGREDIENT_PREPARED:
				match held_item:
					Cooking.IngredientPrepared.SCRAPED_CARROT:
						prepare_timer(Cooking.IngredientPrepared.CHOPPED_CARROT, Cooking.HeldItemType.INGREDIENT_PREPARED, 0, 3)
					Cooking.IngredientPrepared.SCRAPED_ONION:
						prepare_timer(Cooking.IngredientPrepared.CHOPPED_ONION, Cooking.HeldItemType.INGREDIENT_PREPARED, 0, 3)
					Cooking.IngredientPrepared.SCRAPED_POTATO:
						prepare_timer(Cooking.IngredientPrepared.CHOPPED_POTATO, Cooking.HeldItemType.INGREDIENT_PREPARED, 0, 3)
					_: return [held_item, item_type]
			_: return [held_item, item_type]

		return [null, null]
	
	else: return [held_item, item_type]

func scrape(held_item, item_type):
	if held_item == null and items[0] != null:
		return take_item(0)

	elif held_item != null and items[0] == null:
		if item_type == Cooking.HeldItemType.INGREDIENT:
			match held_item:
				Cooking.Ingredient.CARROT:
					prepare_timer(Cooking.IngredientPrepared.SCRAPED_CARROT, Cooking.HeldItemType.INGREDIENT_PREPARED, 0, 3)
				Cooking.Ingredient.ONION:
					prepare_timer(Cooking.IngredientPrepared.SCRAPED_ONION, Cooking.HeldItemType.INGREDIENT_PREPARED, 0, 3)
				Cooking.Ingredient.POTATO:
					prepare_timer(Cooking.IngredientPrepared.SCRAPED_POTATO, Cooking.HeldItemType.INGREDIENT_PREPARED, 0, 3)
				_: return [held_item, item_type]
		else:
			return [held_item, item_type]
			
		return [null, null]
	
	else: return [held_item, item_type]

func mill(held_item, item_type):
	if held_item == null and items[0] != null:
		return take_item(0)

	elif items[0] == null and item_type == Cooking.HeldItemType.INGREDIENT_PREPARED and held_item == Cooking.IngredientPrepared.CHOPPED_TOMATO:
		prepare_timer(Cooking.IngredientPrepared.TOMATO_PASTE, Cooking.HeldItemType.INGREDIENT_PREPARED, 0, 3)

		return [null, null]
		
	return [held_item, item_type]

func sink(held_item, item_type):
	if held_item == null:
		if items[0] == null: # spawning an empty pot (take from cupboard)
			put_item(Cooking.Pot.EMPTY, Cooking.HeldItemType.POT, 0)

		else:
			update_utensil(Cooking.UtensilType.SINK)
		
		return take_item(0)
	
	elif items[0] == null and item_type == Cooking.HeldItemType.POT:
		if held_item == Cooking.Pot.EMPTY:
			update_utensil(Cooking.UtensilType.SINK_RUNNING)
			prepare_timer(Cooking.Pot.WATER, Cooking.HeldItemType.POT, 0, 2)

		else: # placing pot with water (or sth else) to free one more oven
			put_item(held_item, item_type, 0)

		return [null, null]

func oven(held_item, item_type):
	if held_item == null:
		if items[0] == null and items[1] == null:
			return [null, null]

		if items[0] != null:
			match items[0]:
				Cooking.Pot.TOMATO_PASTE_BOILING:
					items[0] = Cooking.IngredientPrepared.TOMATO_PASTE
					item_types[0] = Cooking.HeldItemType.INGREDIENT_PREPARED
					
				Cooking.Pot.CHICKEN_BROTH_BOILING:
					items[0] = Cooking.Dish.CHICKEN_SOUP
					item_types[0] = Cooking.HeldItemType.DISH
				
				Cooking.Pot.TOMATO_SOUP_BOILING:
					items[0] = Cooking.Dish.TOMATO_SOUP
					item_types[0] = Cooking.HeldItemType.DISH
				
				Cooking.Pot.RICE_BEANS_BOILING:
					items[0] = Cooking.Dish.BEANS_RICE
					item_types[0] = Cooking.HeldItemType.DISH
			
			update_utensil(Cooking.UtensilType.OVEN)
			return take_item(0)
		
		# if nothing in hand but something in roast slot
		if items[1] != null:
			update_utensil(Cooking.UtensilType.OVEN)
			return take_item(1)

	else: # held_item != null
		if items[0] == null and items[1] == null:
			if item_type == Cooking.HeldItemType.POT:
				put_item(held_item, item_type, 0)
				return [null, null]
			
			if item_type == Cooking.HeldItemType.INGREDIENT_PREPARED and held_item in [Cooking.IngredientPrepared.ROASTED_BEEF, Cooking.IngredientPrepared.ROASTED_POTATO]:
				put_item(held_item, item_type, 1)
				return [null, null]
			
			# roasting below
			if item_type == Cooking.HeldItemType.INGREDIENT and held_item == Cooking.Ingredient.BEEF:
				update_utensil(Cooking.UtensilType.OVER_ROAST)
				prepare_timer(Cooking.IngredientPrepared.ROASTED_BEEF, Cooking.HeldItemType.INGREDIENT_PREPARED, 1, 10)

			elif item_type == Cooking.HeldItemType.INGREDIENT_PREPARED and held_item == Cooking.IngredientPrepared.CHOPPED_POTATO:
				update_utensil(Cooking.UtensilType.OVER_ROAST)
				prepare_timer(Cooking.IngredientPrepared.ROASTED_POTATO, Cooking.HeldItemType.INGREDIENT_PREPARED, 1, 10)

			return [null, null]
		
		if items[0] != null and item_types[0] == Cooking.HeldItemType.POT:
			if items[0] == Cooking.Pot.WATER:
				if item_type == Cooking.HeldItemType.INGREDIENT_PREPARED:
					match held_item:
						Cooking.IngredientPrepared.MILLED_TOMATO:
							put_item(Cooking.Pot.TOMATO_PASTE, Cooking.HeldItemType.POT, 0)
							update_utensil(Cooking.UtensilType.OVEN_COOK)
							prepare_timer(Cooking.Pot.TOMATO_PASTE_BOILING, Cooking.HeldItemType.POT, 0, 10)

						Cooking.IngredientPrepared.CHOPPED_CARROT:
							put_item(Cooking.Pot.CARROTS, Cooking.HeldItemType.POT, 0)
							return [null, null]
						
						_: return [held_item, item_type]

				elif item_type == Cooking.HeldItemType.INGREDIENT and held_item == Cooking.Ingredient.RICE:
					put_item(Cooking.Pot.RICE, Cooking.HeldItemType.POT, 0)

				else: return [held_item, item_type]
			
			elif items[0] == Cooking.Pot.CARROTS and item_type == Cooking.HeldItemType.INGREDIENT_PREPARED and held_item == Cooking.IngredientPrepared.CHOPPED_ONION:
				put_item(Cooking.Pot.CARROTS_ONIONS, Cooking.HeldItemType.POT, 0)
			
			elif items[0] == Cooking.Pot.CARROTS_ONIONS and item_type == Cooking.HeldItemType.INGREDIENT and held_item == Cooking.Ingredient.CHICKEN:
				put_item(Cooking.Pot.CARROTS_ONIONS_CHICKEN, Cooking.HeldItemType.POT, 0)
				update_utensil(Cooking.UtensilType.OVEN_COOK)
				prepare_timer(Cooking.Pot.CHICKEN_BROTH_BOILING, Cooking.HeldItemType.POT, 0, 10)
			
			elif items[0] == Cooking.Pot.CHICKEN_BROTH_BOILING and item_type == Cooking.HeldItemType.INGREDIENT_PREPARED and held_item == Cooking.IngredientPrepared.TOMATO_PASTE:
				put_item(Cooking.Pot.CHICKEN_BROTH_TOMATO_PASTE, Cooking.HeldItemType.POT, 0)
				update_utensil(Cooking.UtensilType.OVEN_COOK)
				prepare_timer(Cooking.Pot.TOMATO_SOUP_BOILING, Cooking.HeldItemType.POT, 0, 10)
			
			elif items[0] == Cooking.Pot.RICE and item_type == Cooking.HeldItemType.INGREDIENT and held_item == Cooking.Ingredient.BEANS:
				put_item(Cooking.Pot.RICE_BEANS, Cooking.HeldItemType.POT, 0)
				update_utensil(Cooking.UtensilType.OVEN_COOK)
				prepare_timer(Cooking.Pot.RICE_BEANS_BOILING, Cooking.HeldItemType.POT, 0, 10)
			
			else: return [held_item, item_type]

			return [null, null]

		if items[1] != null and item_types[1] == Cooking.HeldItemType.INGREDIENT_PREPARED and item_type == Cooking.HeldItemType.INGREDIENT_PREPARED:
			var first = items[1] == Cooking.IngredientPrepared.ROASTED_BEEF and held_item == Cooking.IngredientPrepared.ROASTED_POTATO
			var second = items[1] == Cooking.IngredientPrepared.ROASTED_POTATO and held_item == Cooking.IngredientPrepared.ROASTED_BEEF

			if first or second:
				put_item(Cooking.Dish.BEEF_POTATOES, Cooking.HeldItemType.DISH, 1)
				update_utensil(Cooking.UtensilType.OVEN)
				return take_item(1)
	
	return [held_item, item_type]
	