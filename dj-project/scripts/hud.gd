extends Control

@onready var time_label: Label = $TimeLabel

func _ready():
	GameClock.connect("time_updated", Callable(self, "_on_time_updated"))
	_on_time_updated(GameClock.day, GameClock.hour)  # Initialize the label right away

func _on_time_updated(day: int, hour: int):
	time_label.text = GameClock.get_time_string()
