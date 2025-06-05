extends Control

@onready var post_container = $PanelContainer/VBoxContainer/ScrollContainer/VBoxContainer
@onready var footer_label = $PanelContainer/VBoxContainer/Footer/Label

var PostScene = preload("res://scenes/post.tscn")
var YourPostsScene = preload("res://scenes/your_post.tscn")
var AddPostScene = preload("res://scenes/add_post.tscn")
var view = "feed"

func _ready():
	update_view()
	FollowerManager.connect("followers_updated", Callable(self, "_on_followers_updated"))
	_on_followers_updated(Global.followers)
	
func update_view():
	for child in post_container.get_children():
		post_container.remove_child(child)
		child.queue_free()
	if view == "feed":
		load_posts_from_json("res://data/posts.json", 0)
	elif view == "add_post":
		add_add_post()
	elif view == "posts":
		load_posts_from_json("res://data/your_posts.json", 1)

func load_posts_from_json(json_path: String, flag: bool):
	var file = FileAccess.open(json_path, FileAccess.READ)
	if file:
		var json_text = file.get_as_text()
		var data = JSON.parse_string(json_text)
		if data is Array:
			for post in data:
				var username = post.get("user", "Unknown")
				var content = post.get("content", "")
				var id = post.get("id", "0")
				if flag:
					var traits = post.get("traits")
					add_your_post(username, content, "res://images/placeholder2.jpg", id, traits)
				else:
					add_post(username, content, "res://images/placeholder2.jpg", id)
		else:
			print("Error: JSON is not an array.")
	else:
		print("Failed to open JSON file at %s" % json_path)

func add_your_post(username: String, text: String, image_path: String, id: String, traits: Dictionary):
		var post_instance = YourPostsScene.instantiate()
		
		post_instance.set_user_data(username, text, image_path, id, traits)
		post_container.add_child(post_instance)

func add_post(username: String, text: String, image_path: String, id: String):
		var post_instance = PostScene.instantiate()
		
		post_instance.set_user_data(username, text, image_path, id)
		post_container.add_child(post_instance)

func add_add_post():
	var add_post_instance = AddPostScene.instantiate()
	
	post_container.add_child(add_post_instance)

func _on_add_post_pressed() -> void:
	if view != "add_post":
		view = "add_post"
		update_view()

func _on_feed_pressed() -> void:
	if view != "feed":
		view = "feed"
		update_view()

func _on_posts_pressed() -> void:
	if view != "posts":
		view = "posts"
		update_view()
	
func _on_exit_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/home.tscn")
	
func _on_followers_updated(followers: int):
	footer_label.text = "Followers: " + str(followers)
