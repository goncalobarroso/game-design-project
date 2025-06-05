extends Control

var user_reactions = {}
var traits = {}


func _ready():
	load_reactions()
	update_reaction_ui()

func set_user_data(username: String, post_text: String, image_path: String, id: String, post_traits: Dictionary):
	print("Setting post data for: ", username)
	traits = post_traits
	print(traits)
	$PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/username.text = username
	$PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/post.text = post_text
	self.set_meta("id", id)

	if image_path != "":
		var tex = load(image_path)
		$PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/TextureRect.texture = tex
	else:
		$PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/TextureRect.visible = false
	update_reaction_ui()

func _on_like_pressed() -> void:
	load_reactions()
	var post_id = get_meta("id")

	if user_reactions.has(post_id):
		return
	else:
		like_post(post_id)

	var total_gain := calculate_follower_gain(traits, "like")
	FollowerManager.schedule_gain(total_gain)
	
	save_reactions()
	update_reaction_ui()

func _on_dislike_pressed() -> void:
	load_reactions()
	var post_id = get_meta("id")
	if user_reactions.has(post_id):
		return
	else:
		dislike_post(post_id)
		
	var total_gain := calculate_follower_gain(traits, "dislike")
	FollowerManager.schedule_gain(total_gain)

	save_reactions()
	update_reaction_ui()

func like_post(post_id: String):
	user_reactions[post_id] = "like"

func dislike_post(post_id: String):
	user_reactions[post_id] = "dislike"

func clear_reaction(post_id: String):
	user_reactions.erase(post_id)

func get_reaction(post_id: String) -> String:
	if user_reactions.has(post_id):
		return user_reactions.get(post_id)
	else:
		return "none"

func save_reactions():
	var file = FileAccess.open("res://data/reactions.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(user_reactions))
	file.close()

func load_reactions():
	if FileAccess.file_exists("res://data/reactions.json"):
		var file = FileAccess.open("res://data/reactions.json", FileAccess.READ)
		var data = JSON.parse_string(file.get_as_text())
		if typeof(data) == TYPE_DICTIONARY:
			user_reactions = data
		file.close()
	else:
		print("ERROR: File doesn't exist.")

func update_reaction_ui():
	var post_id = get_meta("id")
	var reaction = get_reaction(post_id)
	
	var like_button = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer2/Like
	var dislike_button = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer2/Dislike
	
	if reaction == "like":
		like_button.modulate = Color(0, 0, 0)  # Green highlight
		like_button.disabled = true
		dislike_button.disabled = true
	elif reaction == "dislike":
		dislike_button.modulate = Color(0, 0, 0)  # Red highlight
		like_button.disabled = true
		dislike_button.disabled = true

func calculate_follower_gain(traits: Dictionary, reaction: String) -> int:
	var base_gain := 100.0  # Base number of followers
	var total_gain := 0.0

	# Determine if the post is negative or positive
	var negativity: float = clamp(traits["controversy"] - traits["constructiveness"], 0.0, 10.0)
	var negativity_multiplier: float = 1.0 + (negativity / 10.0)

	total_gain = base_gain * negativity_multiplier

	var is_negative : bool = traits["controversy"] > traits["constructiveness"]

	if is_negative:
		# Negative post
		if reaction == "like":
			return int(total_gain)  # Gain followers
		else:
			return -int(total_gain)  # Lose followers
	else:
		# Positive post
		if reaction == "like":
			return -int(total_gain)  # Lose followers
		else:
			return int(total_gain)  # Gain followers
