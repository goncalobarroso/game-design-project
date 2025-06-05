extends Control

var user_reactions = {}

func _ready():
	load_reactions()
	update_reaction_ui()

func set_user_data(username: String, post_text: String, image_path: String, id: String):
	print("Setting post data for: ", username)
	
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
		if user_reactions[post_id] == "like":
			clear_reaction(post_id)
		else:
			like_post(post_id)
	else:
		like_post(post_id)
	
	save_reactions()
	update_reaction_ui()

func _on_dislike_pressed() -> void:
	load_reactions()
	var post_id = get_meta("id")
	if user_reactions.has(post_id):
		if user_reactions[post_id] == "dislike":
			clear_reaction(post_id)
		else:			
			dislike_post(post_id)
	else:
		dislike_post(post_id)

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
		like_button.modulate = Color(0.2, 1, 0.2)  # Green highlight
		dislike_button.modulate = Color(1, 1, 1)   # Reset
	elif reaction == "dislike":
		like_button.modulate = Color(1, 1, 1)
		dislike_button.modulate = Color(1, 0.2, 0.2)  # Red highlight
	elif reaction == "none":
		like_button.modulate = Color(1, 1, 1)
		dislike_button.modulate = Color(1, 1, 1)
