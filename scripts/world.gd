extends Node3D

@export var swap_scene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	$Timers/StartMusic.start()
	$PauseMenu.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		print("Escape")
		get_tree().paused = not get_tree().paused
		$PauseMenu.visible = not $PauseMenu.visible
	if Input.is_action_just_pressed('quit'):
		get_tree().change_scene_to_file("res://scenes/start_world.tscn")

func level_end():
	$RobotHero.wind_down()
	$Timers/LevelEndTimer.start()
	
func player_fell():
	get_tree().reload_current_scene()
	
func player_got_hit():
	$RobotHero.explode()
	$Timers/DeadTimer.start()
	
func _on_start_music_timeout():
	$SFX/SFXMusic.play()

func _on_floor_boundary_body_entered(body):
	if body.name == "RobotHero":
		$SFX/SFXFell.play()
		$Timers/DeadTimer.start()


func _on_dead_timer_timeout():
	player_fell()


func _on_level_end_timer_timeout():
	get_tree().change_scene_to_packed(swap_scene)
