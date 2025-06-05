extends Control

const POSTS_FILE_PATH := "res://data/your_posts.json"
const POST_ID_FILE_PATH := "res://data/post_id_counter.txt"
const REACTIONS_PATH := "res://data/reactions.json"

func _ready() -> void:
	$AnimationPlayer.play("RESET")

func resume():
	get_tree().paused = false
	$AnimationPlayer.play_backwards("blur")

func pause():
	get_tree().paused = true
	$AnimationPlayer.play("blur")
	
func testEsc():
	if Input.is_action_just_pressed("escape") and !get_tree().paused:
		pause()
	elif Input.is_action_just_pressed("escape") and get_tree().paused:
		resume()

func _on_resume_button_pressed() -> void:
	resume()

func _on_exit_button_pressed() -> void:
	get_tree().quit()

func _on_restart_button_pressed() -> void:
	clear_memory()
	resume()
	get_tree().reload_current_scene()

func _process(delta: float) -> void:
	testEsc()

func clear_memory() ->  void:
	GameState.player_position=Vector2.ZERO
	GameClock.reset_clock()
	Global.clear_data()
	FollowerManager.clear_data()
	var posts_file = FileAccess.open(POSTS_FILE_PATH, FileAccess.WRITE)
	if posts_file:
		posts_file.store_string("")  # or "[]" if it's meant to be a list
		posts_file.close()
	var id_counter_file = FileAccess.open(POST_ID_FILE_PATH, FileAccess.WRITE)
	if id_counter_file:
		id_counter_file.store_string("")  # or "[]" if it's meant to be a list
		id_counter_file.close()
	var reactions_file = FileAccess.open(REACTIONS_PATH, FileAccess.WRITE)
	if reactions_file:
		reactions_file.store_string("")  # or "[]" if it's meant to be a list
		reactions_file.close()
