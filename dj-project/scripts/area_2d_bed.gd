extends Area2D

var player_inside = false  # Tracks if player is in the area

func _ready() -> void:
	$"../BedLabel".hide()

func _on_body_entered(body: Node2D) -> void:
	print("Entered bed area!")
	$"../BedLabel".show()
	if body.is_in_group("player"):
		player_inside = true	

func _on_body_exited(body: Node2D) -> void:
	print("Exited bed area!")
	$"../BedLabel".hide()
	if body.is_in_group("player"):
		player_inside = false

func _process(delta: float) -> void:
	if player_inside and Input.is_action_just_pressed("interact"):
		$"../Interact".play()
		if can_sleep():
			GameClock.advance_day()
		
func can_sleep() -> bool:
	return GameClock.hour >= 20 or GameClock.hour < 6
	
