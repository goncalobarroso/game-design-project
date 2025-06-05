extends Area2D

var player_inside = false  # Tracks if player is in the area

func _ready() -> void:
	$"../DeskLabel".hide()

func _on_body_entered(body: Node2D) -> void:
	print("Entered desk area!")
	$"../DeskLabel".show()
	if body.is_in_group("player"):
		player_inside = true	

func _on_body_exited(body: Node2D) -> void:
	print("Exited desk area!")
	$"../DeskLabel".hide()
	if body.is_in_group("player"):
		player_inside = false

func _process(delta: float) -> void:
	if player_inside and Input.is_action_just_pressed("interact"):
		GameState.player_position = $"../Player".global_position
		get_tree().change_scene_to_file("res://scenes/social_media.tscn")
		print("E pressed on desk!")
