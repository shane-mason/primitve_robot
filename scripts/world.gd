extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	$Timers/StartMusic.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func level_end():
	$RobotHero.wind_down()
	$Timers/LevelEndTimer.start()
	
func player_dead():
	get_tree().reload_current_scene()
	
func _on_start_music_timeout():
	$SFX/SFXMusic.play()

func _on_floor_boundary_body_entered(body):
	if body.name == "RobotHero":
		$SFX/SFXFell.play()
		$Timers/DeadTimer.start()


func _on_dead_timer_timeout():
	player_dead()


func _on_level_end_timer_timeout():
	get_tree().reload_current_scene()
