extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	$Timers/StartMusic.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func level_end():
	pass

func player_dead():
	pass
	
func _on_start_music_timeout():
	$SFX/SFXMusic.play()
