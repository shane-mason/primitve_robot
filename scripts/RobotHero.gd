extends CharacterBody3D


@export var speed = 10
@export var acceleration = 0.1
@export var damper = .5
@export var bump_jump = .2
@export var jump_velocity = 10
@export var eye_ramp: Gradient
@export var body_rotation_speed = 5.0
@export var body_lean_speed = .5
@export var wind_down_damper = .01

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") + 16
var _eye_material
var _eye_buffer = 0
var dead = false

enum MotionState{
	idle,
	move_left,
	move_right,
	jump,
	jump_left,
	jump_right,
	paused,
	unpaused,
	wind_down
}

var _prev_state = MotionState.idle
var _new_state = MotionState.idle

func _ready():
	$HintLabel.text = "A - Move Left\nB - Move Right"
	$HintLabel.visible = true
	$TimerHint.start()

	$BodyParts/EyeMesh.mesh.material.albedo_color = eye_ramp.sample(0)
	#$SFXMotor.play()

func _handle_jump():
	velocity.y = jump_velocity
	#turn the lights on
	_eye_buffer = 1
	$BodyParts/EyeMesh.mesh.material.albedo_color = eye_ramp.sample(_eye_buffer)
	$SFXJump.play()
		

func _handle_eyes():
	#decrement eyes if we need to
	if _eye_buffer > 0:
		_eye_buffer -= .02
		$BodyParts/EyeMesh.mesh.material.albedo_color = eye_ramp.sample(_eye_buffer)

func _handle_move(direction):

	if abs(velocity.x) < speed:
		velocity.x += direction.x * acceleration

func _handle_dampen():
	velocity.x = move_toward(velocity.x, 0, damper)

func _handle_gravity(delta):
	velocity.y -= gravity * delta

func _handle_wheel():
	$BodyParts/WheelMesh.rotation_degrees.x += velocity.x;
	match _new_state:
		MotionState.move_left, MotionState.move_right:
			$BodyParts/WheelParticles.emitting = true
		_:
			$BodyParts/WheelParticles.emitting = false

func _handle_wind_down():
	$BodyParts/WheelParticles.emitting = false
	velocity.x = move_toward(velocity.x, 0, wind_down_damper)
	print(velocity.x)
	move_and_slide()

func _handle_rotation():
	match _new_state:
		MotionState.jump_right, MotionState.move_right:
			if $BodyParts.rotation_degrees.y > 0:
				$BodyParts.rotation_degrees.y = maxf(0, $BodyParts.rotation_degrees.y-body_rotation_speed)
			if $BodyParts.rotation_degrees.z > -10:
				$BodyParts.rotation_degrees.z-=.5
		MotionState.jump_left, MotionState.move_left:
			if $BodyParts.rotation_degrees.y < 180:
				$BodyParts.rotation_degrees.y = minf(180, $BodyParts.rotation_degrees.y+body_rotation_speed)
			if $BodyParts.rotation_degrees.z > -10:
				$BodyParts.rotation_degrees.z-=.5
		_:
			if $BodyParts.rotation_degrees.z < 0:
				$BodyParts.rotation_degrees.z+=.5

		

func _handle_state(delta):
	match _new_state:
		MotionState.paused:
			return
		MotionState.wind_down:
			_handle_wind_down()
			return
	_prev_state = _new_state
	
	#determine new state
	var _jump_requested = false
	var _bump_jump_requested = false
	var _move_requested = false
	
	if Input.is_action_just_pressed("move_jump") and is_on_floor():
		_jump_requested = true
	elif Input.is_action_pressed("move_jump"):
		_bump_jump_requested = true
		velocity.y += bump_jump
		
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		
		_move_requested = true
		if is_on_floor() and not _jump_requested:
			if direction.x > 0:
				_new_state = MotionState.move_right
			else:
				_new_state = MotionState.move_left
		else:
			if direction.x > 0:
				_new_state = MotionState.jump_right
			else:
				_new_state = MotionState.jump_left
	else:
		if not is_on_floor() or _jump_requested:
			_new_state = MotionState.jump
		else:
			_new_state = MotionState.idle
		
	if _move_requested:
		_handle_move(direction)
	else:
		_handle_dampen()
	if _jump_requested:
		_handle_jump()
		
	_handle_gravity(delta)
	_handle_eyes()
	_handle_wheel()
	_handle_rotation()
	move_and_slide()

func _physics_process(delta):
	_handle_state(delta)
			

func show_hint(hint_text):
	$HintLabel.text = hint_text
	$HintLabel.visible = true
	$TimerHint.start()

func pause():
	_new_state = MotionState.paused
	
func unpause():
	_new_state = MotionState.unpaused
	
func wind_down():
	_new_state = MotionState.wind_down
	
func _on_timer_hint_timeout():
	$HintLabel.visible = false


func _on_sfx_fell_finished():
	get_tree().reload_current_scene()  
