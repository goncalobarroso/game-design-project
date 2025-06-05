extends Control

@onready var time_label: Label = $TimeLabel
@onready var followers_label: Label = $FollowerLabel

func _ready():
	GameClock.connect("time_updated", Callable(self, "_on_time_updated"))
	_on_time_updated(GameClock.day, GameClock.hour)  # Initialize the label right away
	FollowerManager.connect("followers_updated", Callable(self, "_on_followers_updated"))
	_on_followers_updated(Global.followers)
	
func _on_time_updated(day: int, hour: int):
	time_label.text = GameClock.get_time_string()

func _on_followers_updated(followers: int):
	followers_label.text = "Followers: " + str(followers)
