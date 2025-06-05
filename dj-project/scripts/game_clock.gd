extends Node

# Game time variables
var day: int = 1
var hour: int = 0
var time_speed: float = 0.2  # how fast time moves (1 = 1 hour per second)
var time_accumulator: float = 0.0

const GAME_CLOCK_PATH := "res://data/game_clock.json"

signal time_updated(day, hour)

func _ready() -> void:
	load_clock()

func _process(delta: float) -> void:
	time_accumulator += delta * time_speed

	if time_accumulator >= 1.0:
		time_accumulator -= 1.0
		advance_time()

func advance_time():
	FollowerManager.tick_hour()
	hour += 1
	if hour >= 24:
		hour = 0
		day += 1
	emit_and_save()

func advance_day():
	day +=1
	hour = 7
	time_accumulator = 0.0
	emit_and_save()

func get_time_string() -> String:
	if hour>12:
		return "Day %d - %01d PM" % [day, hour-12]
	return "Day %d - %01d AM" % [day, hour]

func reset_clock():
	day = 1
	hour = 0
	time_accumulator = 0.0
	
func emit_and_save():
	var clock_data = {
		"day": day,
		"hour": hour
	}
	var file = FileAccess.open(GAME_CLOCK_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(clock_data))
		file.close()

	emit_signal("time_updated", day, hour)

func load_clock():
	if not FileAccess.file_exists(GAME_CLOCK_PATH):
		print("No saved clock found.")
		day = 1
		hour = 0
		return

	var file = FileAccess.open(GAME_CLOCK_PATH, FileAccess.READ)
	if file:
		var content = file.get_as_text()
		var parsed = JSON.parse_string(content)

		if parsed != null and parsed.has("day") and parsed.has("hour"):
			day = int(parsed["day"])
			hour = int(parsed["hour"])
			print("Clock loaded: Day %d, Hour %d" % [day, hour])
		else:
			print("Invalid clock data.")

func get_day():
	return day

func get_hour():
	return hour
