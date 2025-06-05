extends Control

@onready var controversy_value_label = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer2/HBoxContainer/ControversyValue
@onready var emotionality_value_label = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer3/HBoxContainer/EmotionalityLabel
@onready var constructiveness_value_label = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer4/HBoxContainer/ContructivenessLabel

var traits := {
	"controversy": 0.0,
	"emotionality": 0.0,
	"constructiveness": 0.0
}

var sentence_data := {}

const POSTS_FILE_PATH := "res://data/your_posts.json"
const POST_ID_FILE_PATH := "res://data/post_id_counter.txt"
const POSTS_PER_DAY := 3

var post_counter: int = 0


func _ready():
	load_sentence_fragments()
	load_post_counter()
	check_if_can_post()

func load_sentence_fragments():
	var file = FileAccess.open("res://data/sentence_fragments.json", FileAccess.READ)
	if file:
		var content = file.get_as_text()
		sentence_data = JSON.parse_string(content)
		if sentence_data == null:
			push_error("Failed to parse sentence_fragments.json")
	print(sentence_data)
	
func load_post_counter() -> void:
	if FileAccess.file_exists(POST_ID_FILE_PATH):
		var file = FileAccess.open(POST_ID_FILE_PATH, FileAccess.READ)
		if file:
			post_counter = int(file.get_as_text().strip_edges())
			file.close()

func generate_post() -> String:
	var post = ""

	for trait_name in traits.keys():
		if sentence_data.has(trait_name):
			var snippets = sentence_data[trait_name]
			for snippet in snippets:
				if int(traits[trait_name]) == int(snippet["threshold"]):
					post += snippet["text"] + " "
					break  # Only use the first matching threshold

	return post.strip_edges()

func set_trait(trait_name: String, value: float) -> void:
	if traits.has(trait_name):
		traits[trait_name] = value

func _on_controversy_slider_value_changed(value: float) -> void:
	controversy_value_label.text = str(int(value))
	set_trait("controversy", value)

func _on_emotionality_slider_value_changed(value: float) -> void:
	emotionality_value_label.text = str(int(value))
	set_trait("emotionality", value)

func _on_constructiveness_slider_value_changed(value: float) -> void:
	constructiveness_value_label.text = str(int(value))
	set_trait("constructiveness", value)

func _on_generate_post_pressed() -> void:
	var post = generate_post()
	print("Generated post: " + post)
	save_post_to_file(post)
	check_if_can_post()
	
	var total_gain := calculate_follower_gain(traits)
	FollowerManager.schedule_gain(total_gain)

func save_post_to_file(post_text: String) -> void:
	post_counter += 1
	save_post_counter()

	var post_data = {
		"id": str(post_counter),
		"day": int(GameClock.get_day()),
		"user": "<user>",
		"content": post_text,
		"traits": traits.duplicate()
	}

	# Load existing posts (if any)
	var posts = []
	if FileAccess.file_exists(POSTS_FILE_PATH):
		var file = FileAccess.open(POSTS_FILE_PATH, FileAccess.READ)
		if file:
			var content = file.get_as_text()
			var parsed = JSON.parse_string(content)
			if typeof(parsed) == TYPE_ARRAY:
				posts = parsed
			file.close()

	# Append new post
	posts.append(post_data)

	# Save all posts back to the file
	var file = FileAccess.open(POSTS_FILE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(posts, "\t"))  # Pretty-printed JSON
		file.close()
		print("Saved post #%d to %s" % [post_counter, POSTS_FILE_PATH])
	else:
		push_error("Failed to save post.")

func save_post_counter() -> void:
	var file = FileAccess.open(POST_ID_FILE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(str(post_counter))
		file.close()
		
func check_if_can_post() -> void:
	var current_day = GameClock.get_day()
	var count = 0

	if not FileAccess.file_exists(POSTS_FILE_PATH):
		return

	var file = FileAccess.open(POSTS_FILE_PATH, FileAccess.READ)
	if file:
		var content = file.get_as_text()
		file.close()

		var posts = JSON.parse_string(content)
		if typeof(posts) != TYPE_ARRAY:
			print("Invalid JSON structure.")
			return

		for post in posts:
			if post.has("day") and post["day"] == current_day:
				count += 1

		if count > POSTS_PER_DAY-1:
			$PanelContainer/MarginContainer/VBoxContainer/GeneratePost.text = "Wait for Day " + str(current_day + 1) + " to post!"
			$PanelContainer/MarginContainer/VBoxContainer/GeneratePost.disabled = true	
		else:
			$PanelContainer/MarginContainer/VBoxContainer/GeneratePost.text = "Generate Post"
			$PanelContainer/MarginContainer/VBoxContainer/GeneratePost.disabled = false
		$PanelContainer/MarginContainer/VBoxContainer/Label2.text = "Posts available: " + str(POSTS_PER_DAY - count)
		
func calculate_follower_gain(traits: Dictionary) -> int:
	var base_gain := 100.0  # Base number of followers
	var total_gain := 0.0

	# Negativity is used to scale follower gain
	var negativity: float = clamp(traits["controversy"] - traits["constructiveness"], 0.0, 10.0)
	var negativity_multiplier: float = 1.0 + (negativity / 10.0)


	# Total adjusted gain (e.g., 20 * 1.5 if negativity is 5)
	total_gain = base_gain * negativity_multiplier
	
	return total_gain
