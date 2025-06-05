extends Node

var pending_gains: Array = []

const PENDING_GAINS_FILE := "res://data/pending_gains.json"

signal followers_updated(followers)

func _ready():
	load_pending_gains()

# Called when a new post is made
func schedule_gain(total_gain: float):
	var gain_data = {
		"remaining_hours": 24,
		"gain_per_hour": total_gain / 24.0
	}
	pending_gains.append(gain_data)
	save_pending_gains()

# Called once per in-game hour
func tick_hour():
	var updated = false
	for gain in pending_gains:
		if gain["remaining_hours"] > 0:
			increase_followers(gain["gain_per_hour"])
			gain["remaining_hours"] -= 1
			print("Added %d followers!" % gain["gain_per_hour"])
			print("Followers: %d" % Global.followers)
			updated = true

	# Remove finished gains
	pending_gains = pending_gains.filter(func(g): return g["remaining_hours"] > 0)

	if updated:
		save_pending_gains()

func increase_followers(followers: int):
	Global.add_followers(followers)
	emit_signal("followers_updated", Global.followers)

# Save to disk
func save_pending_gains():
	var file = FileAccess.open(PENDING_GAINS_FILE, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(pending_gains))
		file.close()

# Load from disk
func load_pending_gains():
	if FileAccess.file_exists(PENDING_GAINS_FILE):
		var file = FileAccess.open(PENDING_GAINS_FILE, FileAccess.READ)
		if file:
			var content = file.get_as_text()
			var parsed = JSON.parse_string(content)
			if typeof(parsed) == TYPE_ARRAY:
				pending_gains = parsed
			else:
				print("Invalid data in pending_gains.json")
			file.close()

func clear_data():
	pending_gains = []
	save_pending_gains()
