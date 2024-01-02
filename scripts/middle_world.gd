extends Node3D

@export var swap_scene: PackedScene;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		get_tree().change_scene_to_packed(swap_scene)



func _on_level_timer_timeout():
	get_tree().change_scene_to_packed(swap_scene)
