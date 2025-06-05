extends Control

var user_reactions = {}

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
