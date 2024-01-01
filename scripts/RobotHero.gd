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
@export var shard_scene: PackedScene
@export var start_paused = false
@export var can_shoot = true
@export var initial_hint = "A - Move Left\nB - Move Right"

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") + 16
var _eye_material
var _eye_buffer = 0

enum MotionState{
	idle_right,
	idle_left,
	move_left,
	move_right,
	jump_idle_right,
	jump_idle_left,
	jump_left,
	jump_right,
	paused,
	unpaused,
	wind_down,
	dead
}

var _prev_state = MotionState.idle_right
var _new_state = MotionState.idle_right
var _bullet_scene
var world_node

func _ready():
	if start_paused:
		_prev_state = MotionState.paused
		_new_state = MotionState.paused
		
	$HintLabel.text = initial_hint
	$HintLabel.visible = true
	$TimerHint.start()
	_bullet_scene = preload("res://scenes/bullet.tscn")
	$BodyParts/EyeMesh.mesh.material.albedo_color = eye_ramp.sample(0)
	#$SFXMotor.play()

func _handle_jump():
	if is_on_floor():
		velocity.y = jump_velocity
		#turn the lights on
		_eye_buffer = 1
	elif is_on_wall_only():
		velocity.y = jump_velocity/2.0
		_eye_buffer = .5
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
	match _new_state:
		MotionState.move_left, MotionState.move_right:
			$BodyParts/WheelParticles.emitting = true
		_:
			$BodyParts/WheelParticles.emitting = false
	match _new_state:
		MotionState.move_left, MotionState.jump_left:
			$BodyParts/WheelMesh.rotation_degrees.x -= velocity.x;
		MotionState.move_right, MotionState.jump_right:
			$BodyParts/WheelMesh.rotation_degrees.x += velocity.x;
			
		

func _handle_wind_down():
	$BodyParts/WheelParticles.emitting = false
	velocity.x = move_toward(velocity.x, 0, wind_down_damper)
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

func _handle_z():
	global_position.z = move_toward(global_position.z, 0 , .001)

	
func _handle_shoot():
	if can_shoot and Input.is_action_pressed("shoot"):
		var direction
		match _new_state:
			MotionState.move_right, MotionState.jump_right, MotionState.jump_idle_right, MotionState.idle_right:
				direction = Vector3(1,-.2,0)
			_:
				direction = Vector3(-1,.05,0)
		var instance = _bullet_scene.instantiate()
		instance.direction = direction
		instance.global_position = $BodyParts/ShootingPoint.global_position;
		$BodyParts/ShootParticles.emitting = true
		get_tree().get_root().get_node("World").add_child(instance)
		can_shoot = false
		$TimerShoot.start()
		

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
	
	if Input.is_action_just_pressed("move_jump") and (is_on_floor() or is_on_wall_only()):
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
			#then we are idle jumping - which direction?
			match _prev_state:
				MotionState.move_right, MotionState.jump_right, MotionState.jump_idle_right, MotionState.idle_right:
					_new_state = MotionState.jump_idle_right
				_:
					_new_state = MotionState.jump_idle_left
		else:
			#then we are idle - which direction?
			match _prev_state:
				MotionState.move_right, MotionState.jump_right, MotionState.jump_idle_right, MotionState.idle_right:
					_new_state = MotionState.idle_right
				_:
					_new_state = MotionState.idle_left
		
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
	_handle_shoot()
	_handle_z()
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

func explode():
	$CollisionShape3D.disabled = true
	var scene = preload("res://scenes/shard.tscn")
	var instance = scene.instantiate()
	instance.global_position = self.global_position
	get_tree().get_root().get_node("World").add_child(instance)
	$TimerDead.start()
	
func _on_timer_hint_timeout():
	$HintLabel.visible = false

func _on_sfx_fell_finished():
	get_tree().reload_current_scene()  


func _on_timer_dead_timeout():
	queue_free()


func _on_timer_shoot_timeout():
	can_shoot = true
