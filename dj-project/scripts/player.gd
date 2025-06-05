extends CharacterBody2D

const SPEED = 130.0
const STEP_INTERVAL = 0.4  # Time between footsteps in seconds

@onready var footstep_player = $Footsteps
@onready var step_timer = $StepTimer  # Make sure you add a Timer node named StepTimer

var footstep_sounds = [
	preload("res://sound/sfx/passo1.mp3"),
	preload("res://sound/sfx/passo2.mp3"),
	preload("res://sound/sfx/passo3.mp3"),
	preload("res://sound/sfx/passo4.mp3"),
	preload("res://sound/sfx/passo5.mp3")
]

func _ready() -> void:
	if GameState.player_position != Vector2.ZERO:
		$"../Player".global_position = GameState.player_position
	footstep_player.volume_db = -12.0
	step_timer.wait_time = STEP_INTERVAL
	step_timer.one_shot = false
	step_timer.start()

func get_input():
	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * SPEED

func _physics_process(delta: float) -> void:
	get_input()
	move_and_slide()

	if velocity.length() > 0 and not footstep_player.playing:
		play_random_footstep()
	else:
		step_timer.stop()

func _on_step_timer_timeout() -> void:
	if velocity.length() > 0:
		play_random_footstep()

func play_random_footstep():
	footstep_player.stream = footstep_sounds[randi() % footstep_sounds.size()]
	footstep_player.play()
