extends Node3D

@export var eye_ramp: Gradient
@export var no_speak_color: Color
@export var dialog:Array[String] = []
@export var eyes:MeshInstance3D


# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	$TimerStart.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _speak():
	eyes.mesh.material.albedo_color = eye_ramp.sample(randf())
	
func _no_speak():
	eyes.mesh.material.albedo_color = no_speak_color

func _speak_this(text):
	if text != "":
		$TimerTalking.start()
		$HintLabel.visible = true
	else:
		$TimerTalking.stop()
		_no_speak()
		$HintLabel.visible = false
		
	$HintLabel.text = text

func _on_timer_start_timeout():
	_speak_this(dialog[0])
	print("Starting to talk...")
	$TimerText.start()
	

func _on_timer_text_timeout():
	_speak_this(dialog[1])
	$TimerText2.start()


func _on_timer_text_2_timeout():
	_speak_this(dialog[2])
	$TimerText3.start()


func _on_timer_talking_timeout():
	_speak()
	$TimerTalking.start(randf_range(0.1, 0.5))


func _on_timer_text_3_timeout():
	_speak_this(dialog[3])
	$TimerEnd.start()
	

func _on_timer_end_timeout():
	_speak_this("")
