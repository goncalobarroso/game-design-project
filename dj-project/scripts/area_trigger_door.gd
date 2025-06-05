extends Area2D

var player_inside = false  # Tracks if player is in the area
var menu_visible = false # Tracks if menu is visible
var menu_scene = preload("res://scenes/scene_menu.tscn")
var menu_instance = menu_scene.instantiate()


func _ready() -> void:
	$"../DoorLabel".hide()
	add_child(menu_instance)
	
func _on_body_entered(body: Node2D) -> void:
	print("Entered door area!")
	$"../DoorLabel".show()
	if body.is_in_group("player"):
		player_inside = true	

func _on_body_exited(body: Node2D) -> void:
	print("Exited door area!")
	$"../DoorLabel".hide()
	if body.is_in_group("player"):
		player_inside = false

func _process(delta: float) -> void:
	if player_inside and Input.is_action_just_pressed("interact"):
		menu_instance.show_menu()
	elif !player_inside :
		menu_instance.hide_menu()
