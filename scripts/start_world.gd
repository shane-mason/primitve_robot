extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		get_tree().change_scene_to_file("res://scenes/world.tscn")
	elif Input.is_action_just_pressed("quit"):                   
		get_tree().quit() 


func _on_button_pressed():
	get_tree().change_scene_to_file("res://scenes/world.tscn")
