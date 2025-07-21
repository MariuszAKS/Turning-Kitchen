extends Control


class StatisticEntry:
	var name: String
	var score: int
	var date: String # YYYY-MM-DD
	var time: String # HH:MM:SS

	func _init(_name: String, _score: int):
		name = _name
		score = _score
		date = Time.get_date_string_from_system()
		time = Time.get_time_string_from_system()

	static func sort_by_name(a: StatisticEntry, b: StatisticEntry):
		return a.name < b.name

	static func sort_by_score(a: StatisticEntry, b: StatisticEntry):
		return a.score < b.score
	
	static func sort_by_date(a: StatisticEntry, b:StatisticEntry):
		return a.time < b.time if a.date == b.date else a.date < b.date


var statistics_entries: Array[StatisticEntry] = []

@export var column_number: VBoxContainer
@export var column_name: VBoxContainer
@export var column_score: VBoxContainer
@export var column_datetime: VBoxContainer

@export var button_sort_name: Button
@export var button_sort_score: Button
@export var button_sort_datetime: Button

@export var button_back: Button


func _ready():
	button_back.pressed.connect(go_back_to_menu)

	statistics_entries = read_statistics_from_memory()
	update_columns()


func update_columns():
	column_clear(column_number)
	column_clear(column_name)
	column_clear(column_score)
	column_clear(column_datetime)

	columns_populate()

func column_clear(column: VBoxContainer):
	for entry in column.get_children():
		entry.queue_free()
		column.remove_child(entry)

func columns_populate():
	var i = 1

	for entry in statistics_entries:
		var number_label = Label.new()
		number_label.text = str(i)
		number_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		column_number.add_child(number_label)

		var name_label = Label.new()
		name_label.text = entry.name
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		column_name.add_child(name_label)

		var score_label = Label.new()
		score_label.text = str(entry.score)
		score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		column_score.add_child(score_label)

		var datetime_label = Label.new()
		datetime_label.text = entry.date + " " + entry.time
		datetime_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		column_datetime.add_child(datetime_label)

		i += 1


func read_statistics_from_memory() -> Array[StatisticEntry]:
	# read the statistics from global script (only from this session) -------------------- TEMPORARY SOLUTION IMPLEMENTED
	
	return [
		StatisticEntry.new("First", 1000),
		StatisticEntry.new("Second", 2000),
		StatisticEntry.new("Third", 1200),
		StatisticEntry.new("Fourth", 100000),
		StatisticEntry.new("Fifth", 500),
		StatisticEntry.new("Sixth", 200),
		StatisticEntry.new("Seventh", 1),
		StatisticEntry.new("Eight", 2),
		StatisticEntry.new("Nineth", 30),
		StatisticEntry.new("Tenth", 40),
	]

func load_statistics_from_file():
	# button on statistics screen allowing to upload file with stats
	pass

func save_statistics_to_file():
	# button on statistics screen allowing to save file with stats
	pass

func go_back_to_menu():
	self.visible = false
