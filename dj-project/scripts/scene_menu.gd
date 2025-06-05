extends Control

var menu_visible = false

func _ready() -> void:
	hide()

func show_menu():
	show()
	get_tree().paused = true
	if !menu_visible:
		$AnimationPlayer.play("blur")
	menu_visible = true
	$PanelContainer/MarginContainer/MainVBox/HBoxContainer/YesButton.grab_focus() 
	
func hide_menu():
	hide()
	get_tree().paused = false
	if menu_visible:
		$AnimationPlayer.play_backwards("blur")
	menu_visible = false

func _on_yes_button_pressed() -> void:
	$AnimationPlayer.play_backwards("blur")
	get_tree().paused = false
	if get_tree().current_scene.name == "home":
		get_tree().change_scene_to_file("res://Scenes/work.tscn")
	elif get_tree().current_scene.name == "work":
		get_tree().change_scene_to_file("res://Scenes/home.tscn")
	

func _on_no_button_pressed() -> void:
	$AnimationPlayer.play_backwards("blur")
	get_tree().paused = false
	hide_menu()
