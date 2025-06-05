extends CharacterBody2D

const SPEED = 130.0

func _ready() -> void:
	if GameState.player_position != Vector2.ZERO:
		$"../Player".global_position = GameState.player_position
	pass

func get_input():
	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * SPEED
	
func _physics_process(delta: float) -> void:
	get_input()
	move_and_slide()
