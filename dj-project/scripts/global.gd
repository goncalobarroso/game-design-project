extends Node

var followers: int = 0
const SAVE_FILE := "res://data/save_data.json"

func _ready() -> void:
	load_data()

func save_data():
	var data = { "followers": followers }
	var file = FileAccess.open(SAVE_FILE, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))
		file.close()

func load_data():
	if FileAccess.file_exists(SAVE_FILE):
		var file = FileAccess.open(SAVE_FILE, FileAccess.READ)
		if file:
			var content = file.get_as_text()
			var data = JSON.parse_string(content)
			if typeof(data) == TYPE_DICTIONARY:
				followers = data.get("followers", 0)
			file.close()

func add_followers(x: int):
	followers+=x
	save_data()
	
func clear_data():
	followers = 0
	save_data()
